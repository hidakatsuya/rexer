module Rexer
  module Commands
    class Install
      include ActionCallable

      def call(env)
        definition = load_definition(env)
        lock_definition = load_lock_definition

        if lock_definition.nil?
          install_initially(definition)
        elsif lock_definition.env != definition.env
          Switch.new.call(env)
        else
          apply_diff(lock_definition, definition)
        end
      end

      private

      def install_initially(definition)
        install(definition.themes, definition.plugins)

        create_lock_file(definition.env)
        print_state
      end

      def apply_diff(lock_definition, definition)
        diff = lock_definition.diff(definition)

        install(diff.added_themes, diff.added_plugins)
        uninstall(diff.deleted_themes, diff.deleted_plugins)
        reload_source(diff.source_changed_themes, diff.source_changed_plugins)

        create_lock_file(definition.env)
        print_state
      end

      def load_definition(env)
        data = Definition.load_data
        data.with(
          plugins: data.plugins.select { _1.env == env },
          themes: data.themes.select { _1.env == env },
          env:
        )
      end

      def load_lock_definition
        Definition::Lock.load_data if Definition::Lock.file.exist?
      end

      def install(themes, plugins)
        themes.each do
          call_action Extension::Theme::Install, _1
        end

        plugins.each do
          call_action Extension::Plugin::Install, _1
        end
      end

      def uninstall(themes, plugins)
        themes.each do
          call_action Extension::Theme::Uninstall, _1
        end

        plugins.each do
          call_action Extension::Plugin::Uninstall, _1
        end
      end

      def reload_source(themes, plugins)
        themes.each do
          call_action Extension::Theme::ReloadSource, _1
        end

        plugins.each do
          call_action Extension::Plugin::ReloadSource, _1
        end
      end

      def create_lock_file(env)
        Definition::Lock.create_file(env)
      end

      def print_state
        State.new.call
      end
    end
  end
end
