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

    class DefinitionFileNotFound < StandardError
      def initialize
        super("No definition file (#{Rexer.definition_file}) found")
      end
    end

    Source = ::Data.define(:type, :options)

    Plugin = ::Data.define(:name, :source, :hooks, :env) do
      include ExtensionComparable
    end

    Theme = ::Data.define(:name, :source, :hooks, :env) do
      include ExtensionComparable
    end

    def self.dir
      @dir ||= find_difinition_dir
    end

    def self.file
      @file ||= dir.join(Rexer.definition_file)
    end

    def self.load_data
      dsl = Dsl.new.tap { _1.instance_eval(file.read) }
      dsl.to_data
    rescue DefinitionFileNotFound
      nil
    end

    def self.find_difinition_dir
      definition_file = Rexer.definition_file
      dir = Pathname.pwd

      until dir.join(definition_file).exist?
        raise DefinitionFileNotFound if dir.root?
        dir = dir.parent
      end

      dir
    end
    private_class_method :find_difinition_dir
  end
end
