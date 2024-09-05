module Rexer
  module Commands
    class Envs
      def initialize
        @definition = Definition.load_data
      end

      def call
        defined_envs = definition.envs
        defined_envs.each.with_index do |env, i|
          puts env

          definition_with(env).then { _1.themes + _1.plugins }.each do
            puts "  #{_1.name} (#{Source.from_definition(_1.source).info})"
          end

          puts if i < defined_envs.size - 1
        end
      end

      private

      attr_reader :definition

      def definition_with(env)
        definition.with(
          plugins: definition.plugins.select { _1.env == env },
          themes: definition.themes.select { _1.env == env }
        )
      end
    end
  end
end
