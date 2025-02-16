module Rexer
  module Extension
    module Plugin
      class Install < Action
        def call
          broadcast(:started, "Install #{plugin.name}")

          if plugin.exist?
            broadcast(:skipped, "Already exists")
            return
          end

          load_from_source
          run_bundle_install
          run_db_migrate
          call_installed_hook

          broadcast(:completed)
        end

        private

        def load_from_source
          plugin.source.load(plugin.path.to_s)
        end

        def run_bundle_install
          return unless plugin.contains_gemfile?

          cmds = build_cmd("bundle", "install", Rexer.verbosity.debug? ? nil : "--quiet")

          broadcast(:processing, "Execute #{cmds}")

          system(cmds, exception: true)
        end

        def call_installed_hook
          Rexer.redmine_root_dir { plugin.hooks[:installed]&.call }
        end
      end
    end
  end
end
