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
