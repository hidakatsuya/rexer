module Rexer
  module Definition
    class Diff
      def initialize(old_data, new_data)
        @old_data = old_data
        @new_data = new_data
      end

      def added_plugins
        new_data.plugins - old_data.plugins
      end

      def added_themes
        new_data.themes - old_data.themes
      end

      def deleted_plugins
        old_data.plugins - new_data.plugins
      end

      def deleted_themes
        old_data.themes - new_data.themes
      end

      def source_changed_plugins
        old_plugins = old_data.plugins

        (new_data.plugins & old_plugins).select do |new_plugin|
          old_plugin = old_plugins.find { _1.name == new_plugin.name }
          plugin_source_changed?(old_plugin, new_plugin)
        end
      end

      def source_changed_themes
        old_themes = old_data.themes

        (new_data.themes & old_themes).select do |new_theme|
          old_theme = old_themes.find { _1.name == new_theme.name }
          theme_source_changed?(old_theme, new_theme)
        end
      end

      private

      attr_reader :old_data, :new_data

      def plugin_source_changed?(old_plugin, new_plugin)
        old_plugin.source != new_plugin.source
      end

      def theme_source_changed?(old_theme, new_theme)
        old_theme.source != new_theme.source
      end
    end
  end
end
