module Rexer
  module Extension
    module Plugin
      class ReloadSource < Action
        def call
          return unless plugin_exists?

          broadcast(:started, "Reload #{name} source")

          reload_source
          run_db_migrate

          broadcast(:completed)
        end

        private

        def reload_source
          plugin_dir.to_s.then { |dir|
            FileUtils.rm_rf(dir)
            source.load(dir)
          }
        end
      end
    end
  end
end
