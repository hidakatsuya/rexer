module Rexer
  module Definition
    Data = ::Data.define(:plugins, :themes, :env, :version) do
      def initialize(plugins:, themes:, env: nil, version: nil)
        super
      end

      def envs
        (plugins.map(&:env) + themes.map(&:env)).uniq.sort
      end

      def diff(other)
        Definition::Diff.new(self, other)
      end
    end
  end
end
