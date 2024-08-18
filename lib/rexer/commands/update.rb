module Rexer
  module Commands
    class Update
      include ActionCallable

      def initialize
        @lock_definition = Definition::Lock.load_data
      end

      def call
        return if no_lock_file_found

        update_themes
        update_plugins
      end

      private

      attr_reader :lock_definition

      def update_plugins
        lock_definition.plugins.each do
          call_action Extension::Plugin::Update, _1
        end
      end

      def update_themes
        lock_definition.themes.each do
          call_action Extension::Theme::Update, _1
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
