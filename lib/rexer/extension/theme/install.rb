module Rexer
  module Extension
    module Theme
      class Install < Base
        def call
          broadcast(:started, "Install #{name}")

          if theme_exists?
            broadcast(:skipped, "Already exists")
            return
          end

          load_from_source
          hooks[:installed]&.call

          broadcast(:completed)
        end

        private

        def load_from_source
          source.load(theme_dir.to_s)
        end
      end
    end
  end
end
