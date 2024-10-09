module Rexer
  module Extension
    module Plugin
      class Install < Action
        def call
          broadcast(:started, "Install #{name}")

          if plugin_exists?
            broadcast(:skipped, "Already exists")
            return
          end

          load_from_source
          run_bundle_install
          run_db_migrate
          hooks[:installed]&.call

          broadcast(:completed)
        end

        private

        def load_from_source
          source.load(plugin_dir.to_s)
        end

        def run_bundle_install
          return unless plugin_dir.join("Gemfile").exist?

          cmds = build_cmd("bundle", "install", Rexer.verbosity.debug? ? nil : "--quiet")

          broadcast(:processing, "Execute #{cmds}")

          system(cmds, exception: true)
        end
      end
    end
  end
end
