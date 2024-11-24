module Rexer
  module Source
    class Github < Git
      def initialize(repo:, branch: nil, tag: nil, ref: nil)
        @repo = repo
        super(url: "https://github.com/#{repo}", branch: branch, tag: tag, ref: ref)
      end

      def info
        "#{@repo}@#{reference_name}"
      end
    end
  end
end
