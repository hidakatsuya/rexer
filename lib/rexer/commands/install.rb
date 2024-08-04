module Rexer
  module Commands
    class Install
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
        update(diff.changed_themes, diff.changed_plugins)

        create_lock_file(definition.env)
        print_state
      end

      def load_definition(env)
        Definition.load_data.tap { |data|
          data.env = env
        }
      end

      def load_lock_definition
        Definition::Lock.load_data if Definition::Lock.file.exist?
      end

      def install(themes, plugins)
        themes.each do
          Extension::Theme::Installer.new(_1).install
        end

        plugins.each do
          Extension::Plugin::Installer.new(_1).install
        end
      end

      def uninstall(themes, plugins)
        themes.each do
          Extension::Theme::Uninstaller.new(_1).uninstall
        end

        plugins.each do
          Extension::Plugin::Uninstaller.new(_1).uninstall
        end
      end

      def update(themes, plugins)
        themes.each do
          Extension::Theme::Updater.new(_1).update
        end

        plugins.each do
          Extension::Plugin::Updater.new(_1).update
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
