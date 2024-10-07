module Rexer
  module Extension
    module Plugin
      class Update < Base
        def call
          return unless plugin_exists?

          broadcast(:started, "Update #{name}")

          unless source.updatable?
            broadcast(:skipped, "Not updatable")
            return
          end

          update_source
          run_db_migrate

          broadcast(:completed)
        end

        private

        def update_source
          source.update(plugin_dir.to_s)
        end
      end
    end
  end
end
