module Rexer
  module Definition
    class Data
      attr_accessor :env
      attr_reader :config, :version

      def initialize(plugins, themes, config, env: nil, version: nil)
        @plugins = plugins
        @themes = themes
        @config = config
        @env = env
        @version = version
      end

      def plugins
        env ? @plugins.select { _1.env == env } : @plugins
      end

      def themes
        env ? @themes.select { _1.env == env } : @themes
      end

      def diff(other)
        Definition::Diff.new(self, other)
      end
    end
  end
end
