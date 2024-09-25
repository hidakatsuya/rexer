module Rexer
  module Commands
    class Reinstall
      include ActionCallable

      Action = Data.define(:install, :uninstall)

      def initialize
        @lock_definition = Definition::Lock.load_data
      end

      def call(extension_name)
        return if no_lock_file_found

        extension, action = find_extension_with_action(extension_name.to_sym)

        if extension.nil?
          puts "#{extension_name} is not installed"
          return
        end

        reinstall(extension, action)
      end

      private

      attr_reader :lock_definition

      def find_extension_with_action(name)
        lock_definition.plugins.find { _1.name == name }&.then do |plugin|
          action = Action.new(Extension::Plugin::Install, Extension::Plugin::Uninstall)
          return [plugin, action]
        end

        lock_definition.themes.find { _1.name == name }&.then do |theme|
          action = Action.new(Extension::Theme::Install, Extension::Theme::Uninstall)
          return [theme, action]
        end
      end

      def reinstall(extension, action)
        call_action action.uninstall, extension
        call_action action.install, extension
      end

      def no_lock_file_found
        lock_definition.nil?.tap { |result|
          puts "No lock file found" if result
        }
      end
    end
  end
end
