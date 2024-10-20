module Rexer
  module Source
    class Base
      # Load the source to the given path.
      def load(_path)
        raise "Not implemented"
      end

      # Update to the latest version of the source.
      def update(_path)
        raise "Not implemented"
      end

      # Check if the source can be updated to a newer version.
      def updatable?
        raise "Not implemented"
      end

      # Return the status of the source.
      def info = ""
    end
  end
end
