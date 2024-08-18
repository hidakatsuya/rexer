require "wisper"

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
        include Wisper::Publisher

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

      class Install < Base
        def call
          return if theme_exists?

          broadcast(:started, "Install #{name}")

          load_from_source
          hooks[:installed]&.call

          broadcast(:completed)
        end

        private

        def load_from_source
          source.load(theme_dir.to_s)
        end
      end

      class Uninstall < Base
        def call
          return unless theme_exists?

          broadcast(:started, "Uninstall #{name}")

          remove_theme
          hooks[:uninstalled]&.call

          broadcast(:completed)
        end

        private

        def remove_theme
          theme_dir.rmtree
        end
      end

      class Update < Base
        def call
          return unless theme_exists?

          broadcast(:started, "Update #{name}")

          update_source

          broadcast(:completed)
        end

        private

        def update_source
          source.update(theme_dir.to_s)
        end
      end

      class ReloadSource < Base
        def call
          return unless theme_exists?

          broadcast(:started, "Reload #{name} source")

          reload_source

          broadcast(:completed)
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
