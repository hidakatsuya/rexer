module Rexer
  module Source
    class Github < Git
      def initialize(repo:, branch: nil, tag: nil, ref: nil)
        @repo = repo
        super(url: "https://github.com/#{repo}", branch: branch, tag: tag, ref: ref)
      end

      def info(work_dir = nil)
        [@repo, reference(short_ref: true) || current_branch(work_dir)].compact.join("@")
      end
    end
  end
end
