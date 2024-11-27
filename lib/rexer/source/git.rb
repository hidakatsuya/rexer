require "git"
require "uri"

module Rexer
  module Source
    class Git < Base
      def initialize(url:, branch: nil, tag: nil, ref: nil)
        @url = url
        @branch = branch
        @tag = tag
        @ref = ref
      end

      def load(path)
        ::Git.clone(url, path).then { checkout(_1) }
      end

      def update(path)
        FileUtils.rm_rf(path)
        load(path)
      end

      def updatable?
        branch || reference.nil?
      end

      def info(work_dir = nil)
        uri = URI.parse(url).then { "#{_1.host}#{_1.path}" }
        ref = reference(short_ref: true) || current_branch(work_dir)

        [uri, ref].compact.join("@")
      end

      private

      attr_reader :url, :branch, :tag

      def checkout(git)
        reference&.then { git.checkout(_1) }
      end

      def reference(short_ref: false)
        branch || tag || ref(short: short_ref)
      end

      def ref(short: false)
        return nil unless @ref
        return @ref unless short

        @ref.match?(/^[a-z0-9]+$/) ? @ref.slice(0, 7) : @ref
      end

      def current_branch(work_dir)
        return nil unless work_dir
        ::Git.open(work_dir).current_branch
      end
    end
  end
end
