module Rexer
  module Extension
    module Plugin
      class ReloadSource < Action
        def call
          return unless plugin.exist?

          broadcast(:started, "Reload #{plugin.name} source")

          reload_source
          run_db_migrate

          broadcast(:completed)
        end

        private

        def reload_source
          plugin.path.rmtree
          plugin.source.load(plugin.path.to_s)
        end
      end
    end
  end
end
