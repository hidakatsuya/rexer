module Rexer
  module Extension
    module Plugin
      def self.dir
        Pathname.new("plugins")
      end
    end
  end
end
