module Rexer
  module Commands
    class Update
      include ActionCallable

      def initialize
        @lock_definition = Definition::Lock.load_data
      end

      def call(extension_names)
        return if no_lock_file_found

        extension_names ||= []
        extension_names.map!(&:to_sym)

        update_themes(extension_names)
        update_plugins(extension_names)
      end

      private

      attr_reader :lock_definition

      def update_plugins(extension_names)
        filter_by_name(lock_definition.plugins, extension_names).each do
          call_action Extension::Plugin::Update, _1
        end
      end

      def update_themes(extension_names)
        filter_by_name(lock_definition.themes, extension_names).each do
          call_action Extension::Theme::Update, _1
        end
      end

      def filter_by_name(extensions, extension_names)
        return extensions unless extension_names.any?
        extensions.select { extension_names.include?(_1.name) }
      end

      def no_lock_file_found
        lock_definition.nil?.tap { |result|
          puts "No lock file found" if result
        }
      end
    end
  end
end
