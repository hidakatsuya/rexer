module Rexer
  module Source
    class Base
      def self.source_names = @source_names ||= []

      def self.inherited(subclass)
        source_names << subclass.name.split("::").last.downcase.to_sym
      end

      def load(_path)
        raise "Not implemented"
      end

      def update(_path)
        raise "Not implemented"
      end

      def info = ""
    end
  end
end
