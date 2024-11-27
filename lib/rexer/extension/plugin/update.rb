module Rexer
  module Extension
    module Plugin
      class Update < Action
        def call
          return unless plugin.exist?

          broadcast(:started, "Update #{plugin.name}")

          unless plugin.source.updatable?
            broadcast(:skipped, "Not updatable")
            return
          end

          update_source
          run_db_migrate

          broadcast(:completed)
        end

        private

        def update_source
          plugin.source.update(plugin.path)
        end
      end
    end
  end
end
