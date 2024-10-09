require "wisper"

module Rexer
  module Extension
    module Theme
      class Action
        include Wisper::Publisher

        def initialize(definition)
          @definition = definition
          @name = definition.name
          @hooks = definition.hooks || {}
        end

        private

        attr_reader :name, :hooks, :definition

        def theme_root_dir
          public_themes = Pathname.pwd.join("public", "themes")

          if public_themes.exist?
            # When Redmine version is v5.1 or older, public/themes is used.
            public_themes
          else
            Pathname.new("themes")
          end
        end

        def theme_dir
          @theme_dir ||= theme_root_dir.join(name.to_s)
        end

        def theme_exists?
          theme_dir.exist? && !theme_dir.empty?
        end

        def source
          @source ||= Source.from_definition(definition.source)
        end
      end
    end
  end
end
