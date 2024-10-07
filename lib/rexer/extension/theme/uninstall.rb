module Rexer
  module Extension
    module Theme
      class Uninstall < Base
        def call
          broadcast(:started, "Uninstall #{name}")

          unless theme_exists?
            broadcast(:skipped, "Not exists")
            return
          end

          remove_theme
          hooks[:uninstalled]&.call

          broadcast(:completed)
        end

        private

        def remove_theme
          theme_dir.rmtree
        end
      end
    end
  end
end
