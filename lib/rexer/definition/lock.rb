module Rexer
  module Definition
    module Lock
      def self.file
        @file ||= Definition.dir.join(Rexer.definition_lock_file)
      end

      def self.load_data
        return nil unless file.exist?

        dsl = Dsl.new.tap { _1.instance_eval(file.read) }
        dsl.to_data
      rescue DefinitionFileNotFound
        nil
      end

      def self.create_file(env)
        dsl = <<~DSL
          lock version: "#{Rexer::VERSION}", env: :#{env}

          #{Definition.file.read}
        DSL
        file.write(dsl)
      end

      class Dsl < Definition::Dsl
        def lock(env:, version:)
          @lock_env = env
          @lock_version = version
        end

        def to_data
          plugins = lock_by_env(@plugins)
          themes = lock_by_env(@themes)
          Definition::Data.new(plugins, themes, @lock_env, @lock_version)
        end

        private

        def lock_by_env(plugins_or_themes)
          plugins_or_themes.select { _1.env == @lock_env }
        end
      end
    end
  end
end
