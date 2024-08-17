module Rexer
  module Definition
    module ExtensionComparable
      def eql?(other)
        name == other.name
      end

      def hash
        name.hash
      end
    end

    Config = ::Data.define(
      # The prefix of the command such as bundle install and bin/rails redmine:plugins:migrate.
      #
      # For example, if the command_prefix is set "docker compose exec -T app",
      # then bundle install will be executed as follows:
      #
      #   docker compose exec -T app bundle install
      #
      :command_prefix
    )

    Source = ::Data.define(:type, :options)

    Plugin = ::Data.define(:name, :source, :hooks, :env) do
      include ExtensionComparable
    end

    Theme = ::Data.define(:name, :source, :hooks, :env) do
      include ExtensionComparable
    end

    def self.file
      @file ||= Pathname.new(Rexer.definition_file)
    end

    def self.load_data
      dsl = Dsl.new.tap { _1.instance_eval(file.read) }
      dsl.to_data
    end
  end
end
