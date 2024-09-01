module Rexer
  module Commands
    class Envs
      def initialize
        @definition = Definition.load_data
      end

      def call
        puts(*defined_envs)
      end

      private

      attr_reader :definition

      def defined_envs
        all_envs = definition.plugins.map(&:env) + definition.themes.map(&:env)
        all_envs.uniq.sort
      end
    end
  end
end
