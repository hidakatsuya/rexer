require "open3"
require "wisper"

module Rexer
  module Extension
    module Plugin
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
          cmds = build_cmd("bundle", "exec", "rake", Rexer.verbosity.debug? ? nil : "-q", "redmine:plugins:migrate", envs:)

          broadcast(:processing, "Execute #{cmds}")

          if Rexer.verbosity.debug?
            system(cmds, exception: true)
          else
            _, error, status = Open3.capture3(cmds)
            raise error unless status.success?
          end
        end

        def source
          @source ||= Source.from_definition(definition.source)
        end

        def build_cmd(*command, envs: {})
          envs_str = envs.map { [_1, _2].join("=") }
          [Rexer.config.command_prefix, *command, *envs_str].compact.join(" ")
        end
      end
    end
  end
end
