module Rexer
  module Extension
    module Theme
      class Uninstall < Action
        def call
          broadcast(:started, "Uninstall #{theme.name}")

          unless theme.exist?
            broadcast(:skipped, "Not exists")
            return
          end

          remove_theme
          call_uninstalled_hook

          broadcast(:completed)
        end

        private

        def remove_theme
          theme.path.rmtree
        end

        def call_uninstalled_hook
          theme.hooks[:uninstalled]&.call
        end
      end
    end
  end
end
