module Rexer
  module Extension
    module Plugin
      class Uninstall < Action
        def call
          broadcast(:started, "Uninstall #{plugin.name}")

          unless plugin.exist?
            broadcast(:skipped, "Not exists")
            return
          end

          reset_db_migration
          remove_plugin
          call_uninstalled_hook

          broadcast(:completed)
        end

        private

        def reset_db_migration
          run_db_migrate("VERSION" => "0")
        end

        def remove_plugin
          plugin.path.rmtree
        end

        def call_uninstalled_hook
          Rexer.redmine_root_dir { plugin.hooks[:uninstalled]&.call }
        end
      end
    end
  end
end
