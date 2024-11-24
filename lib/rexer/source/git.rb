require "git"

module Rexer
  module Source
    class Git < Base
      def initialize(url:, branch: nil, tag: nil, ref: nil)
        @url = url
        @branch = branch.presence
        @tag = tag.presence
        @ref = ref.presence
      end

      def load(path)
        ::Git.clone(url, path).then { checkout(_1) }
      end

      def update(path)
        FileUtils.rm_rf(path)
        load(path)
      end

      def updatable?
        @branch || [@branch, @tag, @ref].all?(&:nil?)
      end

      def info
        branch || tag || ref || "master"
      end

      private

      attr_reader :url, :branch, :tag, :ref

      def checkout(git)
        (branch || tag || ref)&.then { git.checkout(_1) }
      end
    end
  end
end
