module Rexer
  module Definition
    class Dsl
      def initialize(env = :default)
        @plugins = []
        @themes = []
        @env = env
      end

      def plugin(name, **opts, &hooks)
        @plugins << Definition::Plugin.new(
          name: name,
          source: build_source(opts),
          hooks: build_hooks(hooks, %i[installed uninstalled updated]),
          env: @env
        )
      end

      def theme(name, **opts, &hooks)
        @themes << Definition::Theme.new(
          name: name,
          source: build_source(opts),
          hooks: build_hooks(hooks, %i[installed uninstalled updated]),
          env: @env
        )
      end

      def env(env_name, &dsl)
        data = self.class.new(env_name).tap { _1.instance_eval(&dsl) }.to_data

        @plugins += data.plugins
        @themes += data.themes
      end

      def to_data
        Definition::Data.new(@plugins, @themes)
      end

      private

      def build_hooks(definition_hooks, availabe_hooks)
        return nil if definition_hooks.nil?

        hook_dsl = Class.new do
          def hooks = @hooks ||= {}

          availabe_hooks.each do |hook_name|
            define_method(hook_name) { |&block| hooks[hook_name] = block }
          end
        end.new

        hook_dsl.instance_eval(&definition_hooks)
        hook_dsl.hooks
      end

      def build_source(opts)
        type = opts.keys.find { Rexer::Source::Base.source_names.include?(_1) }
        Source.new(type, opts[type]) if type
      end
    end
  end
end
