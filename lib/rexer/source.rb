module Rexer
  module Source
    TYPE = {
      git: Git,
      github: Github
    }.freeze

    def self.from_definition(source)
      TYPE[source.type].new(**source.options)
    end
  end
end
