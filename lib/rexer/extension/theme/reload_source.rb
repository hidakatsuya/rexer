module Rexer
  module Extension
    module Theme
      class ReloadSource < Base
        def call
          return unless theme_exists?

          broadcast(:started, "Reload #{name} source")

          reload_source

          broadcast(:completed)
        end

        private

        def reload_source
          theme_dir.to_s.then { |dir|
            FileUtils.rm_rf(dir)
            source.load(dir)
          }
        end
      end
    end
  end
end
