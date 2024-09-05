module Rexer
  module Definition
    class Dsl
      def initialize
        @plugins = []
        @themes = []
        @env = :default
      end

      class EnvDsl < self
        def initialize(env)
          super()
          @env = env
        end
      end

      def plugin(name, **opts, &hooks)
        @plugins << Definition::Plugin.new(
          name: name,
          source: build_source(opts),
          hooks: build_hooks(hooks, %i[installed uninstalled]),
          env: @env
        )
      end

      def theme(name, **opts, &hooks)
        @themes << Definition::Theme.new(
          name: name,
          source: build_source(opts),
          hooks: build_hooks(hooks, %i[installed uninstalled]),
          env: @env
        )
      end

      def env(*env_names, &dsl)
        env_names.each do |env_name|
          data = EnvDsl.new(env_name).tap { _1.instance_eval(&dsl) }.to_data

          @plugins += data.plugins
          @themes += data.themes
        end
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
        type = opts.keys.find { Rexer::Source.names.include?(_1) }
        Source.new(type, opts[type]) if type
      end
    end
  end
end
