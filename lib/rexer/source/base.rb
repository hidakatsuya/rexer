module Rexer
  module Source
    class Base
      def self.inherited(subclass)
        Source.names << subclass.name.split("::").last.downcase.to_sym
      end

      # Load the source to the given path.
      def load(_path)
        raise "Not implemented"
      end

      # Update to the latest version of the source.
      def update(_path)
        raise "Not implemented"
      end

      def info = ""
    end
  end
end
