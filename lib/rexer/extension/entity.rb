require "active_support/core_ext/class/attribute"

module Rexer
  module Extension
    module Entity
      class Base
        class_attribute :root_dir

        def initialize(definition)
          @definition = definition
          @hooks = definition.hooks || {}
          @name = definition.name
        end

        attr_reader :hooks, :name

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
        self.root_dir = Pathname.new("plugins")

        def contains_db_migrations?
          path.join("db", "migrate").then { _1.exist? && !_1.empty? }
        end

        def contains_gemfile?
          path.join("Gemfile").exist?
        end
      end

      class Theme < Base
        self.root_dir = Pathname.new("themes")
      end
    end
  end
end
