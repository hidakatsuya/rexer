module Rexer
  module Extension
    module Theme
      class Install < Action
        def call
          broadcast(:started, "Install #{theme.name}")

          if theme.exist?
            broadcast(:skipped, "Already exists")
            return
          end

          load_from_source
          call_installed_hook

          broadcast(:completed)
        end

        private

        def load_from_source
          theme.source.load(theme.path.to_s)
        end

        def call_installed_hook
          theme.hooks[:installed]&.call
        end
      end
    end
  end
end
