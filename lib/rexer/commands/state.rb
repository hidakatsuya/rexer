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
        plugin_defs = lock_definition.plugins
        return if plugin_defs.empty?

        puts "\nPlugins:"
        plugin_defs.each do
          plugin = Extension::Entity::Plugin.new(_1)
          puts " * #{plugin.name} (#{plugin.source_info})"
        end
      end

      def print_themes
        theme_defs = lock_definition.themes
        return if theme_defs.empty?

        puts "\nThemes:"
        theme_defs.each do
          theme = Extension::Entity::Theme.new(_1)
          puts " * #{theme.name} (#{theme.source_info})"
        end
      end

      def no_lock_file_found
        lock_definition.nil?.tap { |result|
          puts "No lock file found" if result
        }
      end
    end
  end
end
