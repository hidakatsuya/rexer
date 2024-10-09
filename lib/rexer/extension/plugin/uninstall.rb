module Rexer
  module Extension
    module Plugin
      class Uninstall < Action
        def call
          broadcast(:started, "Uninstall #{name}")

          unless plugin_exists?
            broadcast(:skipped, "Not exists")
            return
          end

          reset_db_migration
          remove_plugin
          hooks[:uninstalled]&.call

          broadcast(:completed)
        end

        private

        def reset_db_migration
          run_db_migrate("VERSION" => "0")
        end

        def remove_plugin
          plugin_dir.rmtree
        end
      end
    end
  end
end
