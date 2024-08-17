require "open3"

module Rexer
  module Extension
    module Plugin
      def self.dir
        Pathname.new("plugins")
      end

      class Base
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
          _, error, status = Open3.capture3(envs, cmd_with_prefix("bin/rails redmine:plugins:migrate"))

          raise error unless status.success?
        end

        def source
          @source ||= Source.from_definition(definition.source)
        end

        def cmd_with_prefix(command)
          [Rexer.config.command_prefix, command].compact.join(" ")
        end
      end

      class Installer < Base
        def install
          return if plugin_exists?

          load_from_source
          run_bundle_install
          run_db_migrate
          hooks[:installed]&.call
        end

        private

        def load_from_source
          source.load(plugin_dir.to_s)
        end

        def run_bundle_install
          return unless plugin_dir.join("Gemfile").exist?

          _, error, status = Open3.capture3(cmd_with_prefix("bundle install"))
          raise error unless status.success?
        end
      end

      class Uninstaller < Base
        def uninstall
          return unless plugin_exists?

          reset_db_migration
          remove_plugin
          hooks[:uninstalled]&.call
        end

        private

        def reset_db_migration
          run_db_migrate("VERSION" => "0")
        end

        def remove_plugin
          plugin_dir.rmtree
        end
      end

      class Updater < Base
        def update
          return unless plugin_exists?

          update_source
          run_db_migrate
        end

        private

        def update_source
          source.update(plugin_dir.to_s)
        end
      end

      class SourceReloader < Base
        def reload
          return unless plugin_exists?

          reload_source
          run_db_migrate
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
