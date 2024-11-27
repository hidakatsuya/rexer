module Rexer
  module Extension
    module Theme
      class ReloadSource < Action
        def call
          return unless theme.exist?

          broadcast(:started, "Reload #{theme.name} source")

          reload_source

          broadcast(:completed)
        end

        private

        def reload_source
          theme.path.rmtree
          theme.source.load(theme.path.to_s)
        end
      end
    end
  end
end
