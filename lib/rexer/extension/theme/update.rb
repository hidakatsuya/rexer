module Rexer
  module Extension
    module Theme
      class Update < Action
        def call
          return unless theme_exists?

          broadcast(:started, "Update #{name}")

          update_source

          broadcast(:completed)
        end

        private

        def update_source
          source.update(theme_dir.to_s)
        end
      end
    end
  end
end
