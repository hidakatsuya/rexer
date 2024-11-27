module Rexer
  module Extension
    module Theme
      class Update < Action
        def call
          return unless theme.exist?

          broadcast(:started, "Update #{theme.name}")

          update_source

          broadcast(:completed)
        end

        private

        def update_source
          theme.source.update(theme.path.to_s)
        end
      end
    end
  end
end
