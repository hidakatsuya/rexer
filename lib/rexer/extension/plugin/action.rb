require "open3"
require "wisper"

module Rexer
  module Extension
    module Plugin
      class Action
        include Wisper::Publisher

        def initialize(definition)
          @definition = definition
          @plugin = Entity::Plugin.new(definition)
        end

        private

        attr_reader :plugin

        def run_db_migrate(extra_envs = {})
          return unless plugin.contains_db_migrations?

          envs = {"NAME" => plugin.name.to_s}.merge(extra_envs)
          cmds = build_cmd("bundle", "exec", "rake", Rexer.verbosity.debug? ? nil : "-q", "redmine:plugins:migrate", envs:)

          broadcast(:processing, "Execute #{cmds}")

          if Rexer.verbosity.debug?
            system(cmds, exception: true)
          else
            _, error, status = Open3.capture3(cmds)
            raise error unless status.success?
          end
        end

        def build_cmd(*command, envs: {})
          envs_str = envs.map { [_1, _2].join("=") }
          [Rexer.config.command_prefix, *command, *envs_str].compact.join(" ")
        end
      end
    end
  end
end
