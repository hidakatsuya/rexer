module Rexer
  module Commands
    class Uninstall
      def initialize
        @lock_definition = Definition::Lock.load_data
      end

      def call
        return if no_lock_file_found

        uninstall_themes
        uninstall_plugins

        delete_lock_file
      end

      private

      attr_reader :lock_definition

      def uninstall_plugins
        lock_definition.plugins.each do
          Extension::Plugin::Uninstaller.new(_1).uninstall
        end
      end

      def uninstall_themes
        lock_definition.themes.each do
          Extension::Theme::Uninstaller.new(_1).uninstall
        end
      end

      def delete_lock_file
        Definition::Lock.file.then { |file|
          file.delete if file.exist?
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
