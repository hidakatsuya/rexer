module Rexer
  module Extension
    module Entity
      class Base
        def initialize(definition)
          @definition = definition
          @hooks = definition.hooks || {}
          @name = definition.name
        end

        attr_reader :hooks, :name

        def root_dir = raise "Not implemented"

        def exist?
          path.exist? && !path.empty?
        end

        def path
          @path ||= root_dir.join(name.to_s)
        end

        def source_info
          @source_info ||= source.info(path)
        end

        def source
          @source ||= Source.from_definition(definition.source)
        end

        private

        attr_reader :definition
      end

      class Plugin < Base
        def root_dir
          @root_dir ||= Rexer.redmine_root_dir.join("plugins")
        end

        def contains_db_migrations?
          path.join("db", "migrate").then { _1.exist? && !_1.empty? }
        end

        def contains_gemfile?
          path.join("Gemfile").exist?
        end
      end

      class Theme < Base
        def root_dir
          @root_dir ||= Rexer.redmine_root_dir.join("themes")
        end
      end
    end
  end
end
