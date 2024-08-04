module Rexer
  module Source
    class Github < Git
      def initialize(repo:, branch: nil, tag: nil, ref: nil)
        super(url: "https://github.com/#{repo}", branch: branch, tag: tag, ref: ref)
      end
    end
  end
end
