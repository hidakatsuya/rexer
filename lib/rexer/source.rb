module Rexer
  module Source
    def self.names = @names ||= []

    def self.from_definition(source)
      const_get(source.type.capitalize).new(**source.options)
    end
  end
end

require_relative "source/base"
require_relative "source/git"
require_relative "source/github"
