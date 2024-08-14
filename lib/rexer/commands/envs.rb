module Rexer
  module Commands
    class Envs
      def initialize
        @definition = Definition.load_data
      end

      def call
        defined_envs.each do
          puts _1
        end
      end

      private

      attr_reader :definition

      def defined_envs
        all_envs = definition.plugins.map(&:env) + definition.themes.map(&:env)
        all_envs.uniq
      end
    end
  end
end
