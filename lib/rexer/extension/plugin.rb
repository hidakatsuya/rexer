require "open3"
require "wisper"

module Rexer
  module Extension
    module Plugin
      def self.dir
        Pathname.new("plugins")
      end

      class Base
        include Wisper::Publisher

        def initialize(definition)
          @definition = definition
          @name = definition.name
          @hooks = definition.hooks || {}
        end

        private

        attr_reader :name, :hooks, :definition

        def plugin_dir
          @plugin_dir ||= Plugin.dir.join(name.to_s)
        end

        def plugin_exists?
          plugin_dir.exist? && !plugin_dir.empty?
        end

        def needs_db_migration?
          plugin_dir.join("db", "migrate").then {
            _1.exist? && !_1.empty?
          }
        end

        def run_db_migrate(extra_envs = {})
          return unless needs_db_migration?

          envs = {"NAME" => name.to_s}.merge(extra_envs)
          cmds = cmd("bundle", "exec", "rake", Rexer.verbosity.debug? ? nil : "-q", "redmine:plugins:migrate")

          broadcast(:processing, "Execute #{cmds} with #{envs}")

          if Rexer.verbosity.debug?
            system(envs, cmds, exception: true)
          else
            _, error, status = Open3.capture3(envs, cmds)
            raise error unless status.success?
          end
        end

        def source
          @source ||= Source.from_definition(definition.source)
        end

        def cmd(*command)
          [Rexer.config.command_prefix, *command].compact.join(" ")
        end
      end

      class Install < Base
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

          cmds = cmd("bundle", "install", Rexer.verbosity.debug? ? nil : "--quiet")

          broadcast(:processing, "Execute #{cmds}")

          system(cmds, exception: true)
        end
      end

      class Uninstall < Base
        def call
          broadcast(:started, "Uninstall #{name}")

          unless plugin_exists?
            broadcast(:skipped, "Not exists")
            return
          end

          reset_db_migration
          remove_plugin
          hooks[:uninstalled]&.call

          broadcast(:completed)
        end

        private

        def reset_db_migration
          run_db_migrate("VERSION" => "0")
        end

        def remove_plugin
          plugin_dir.rmtree
        end
      end

      class Update < Base
        def call
          return unless plugin_exists?

          broadcast(:started, "Update #{name}")

          unless source.updatable?
            broadcast(:skipped, "Not updatable")
            return
          end

          update_source
          run_db_migrate

          broadcast(:completed)
        end

        private

        def update_source
          source.update(plugin_dir.to_s)
        end
      end

      class ReloadSource < Base
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
