require "wisper"

module Rexer
  module Extension
    module Theme
      class Action
        include Wisper::Publisher

        def initialize(definition)
          @definition = definition
          @theme = Entity::Theme.new(definition)
        end

        private

        attr_reader :theme
      end
    end
  end
end
