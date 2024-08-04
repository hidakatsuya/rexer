module Rexer
  module Commands
    class State
      def initialize
        @lock_definition = Definition::Lock.load_data
      end

      def call
        return if no_lock_file_found

        puts "Rexer: #{lock_definition.version}"
        puts "Env: #{lock_definition.env}"

        print_themes
        print_plugins
      end

      private

      attr_reader :lock_definition

      def print_plugins
        plugins = lock_definition.plugins
        return if plugins.empty?

        puts "\nPlugins:"
        plugins.each do
          puts " * #{_1.name} (#{source_info(_1.source)})"
        end
      end

      def print_themes
        themes = lock_definition.themes
        return if themes.empty?

        puts "\nThemes:"
        themes.each do
          puts " * #{_1.name} (#{source_info(_1.source)})"
        end
      end

      def source_info(source_def)
        source_def.then {
          Source.const_get(_1.type.capitalize).new(**_1.options).info
        }
      end

      def no_lock_file_found
        lock_definition.nil?.tap { |result|
          puts "No lock file found" if result
        }
      end
    end
  end
end
