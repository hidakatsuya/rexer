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

          themes_in(env) do
            print_extension_definition(_1)
          end

          plugins_in(env) do
            print_extension_definition(_1)
          end

          puts if i < defined_envs.size - 1
        end
      end

      private

      attr_reader :definition

      def print_extension_definition(extension_def)
        puts "  #{extension_def.name} (#{Source.from_definition(extension_def.source).info})"
      end

      def themes_in(env)
        definition.themes.each do
          yield _1 if _1.env == env
        end
      end

      def plugins_in(env)
        definition.plugins.each do
          yield _1 if _1.env == env
        end
      end
    end
  end
end
