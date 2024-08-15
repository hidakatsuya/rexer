module Rexer
  module Extension
    module Theme
      def self.dir
        public_themes = Pathname.pwd.join("public", "themes")

        if public_themes.exist?
          # When Redmine version is v5.1 or older, public/themes is used.
          public_themes
        else
          Pathname.new("themes")
        end
      end

      class Base
        def initialize(definition)
          @definition = definition
          @name = definition.name
          @hooks = definition.hooks || {}
        end

        private

        attr_reader :name, :hooks, :definition

        def theme_dir
          @theme_dir ||= Theme.dir.join(name.to_s)
        end

        def theme_exists?
          theme_dir.exist? && !theme_dir.empty?
        end

        def source
          @source ||= Source.from_definition(definition.source)
        end
      end

      class Installer < Base
        def install
          return if theme_exists?

          load_from_source
          hooks[:installed]&.call
        end

        private

        def load_from_source
          source.load(theme_dir.to_s)
        end
      end

      class Uninstaller < Base
        def uninstall
          return unless theme_exists?

          remove_theme
          hooks[:uninstalled]&.call
        end

        private

        def remove_theme
          theme_dir.rmtree
        end
      end

      class Updater < Base
        def update
          return unless theme_exists?

          update_source
          hooks[:updated]&.call
        end

        private

        def update_source
          source.update(theme_dir.to_s)
        end
      end

      class SourceReloader < Base
        def reload
          return unless theme_exists?

          reload_source
        end

        private

        def reload_source
          theme_dir.to_s.then { |dir|
            FileUtils.rm_rf(dir)
            source.load(dir)
          }
        end
      end
    end
  end
end
