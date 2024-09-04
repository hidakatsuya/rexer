module Rexer
  module Commands
    class Envs
      def initialize
        @definition = Definition.load_data
      end

      def call
        envs = defined_envs
        envs.each.with_index do |env_name, i|
          puts env_name

          definition = definition_on(env_name)
          definition.then { _1.themes + _1.plugins }.each do
            puts "  #{_1.name} (#{Source.from_definition(_1.source).info})"
          end

          puts if i < envs.size - 1
        end
      end

      private

      attr_reader :definition

      def defined_envs
        all_envs = definition.plugins.map(&:env) + definition.themes.map(&:env)
        all_envs.uniq.sort
      end

      def definition_on(env)
        Definition.load_data.tap { |data|
          data.env = env
        }
      end
    end
  end
end
