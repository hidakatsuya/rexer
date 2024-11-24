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
        @reference = branch || tag || ref
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

      def info
        URI.parse(url).then do |uri|
          "#{uri.host}#{uri.path}@#{reference_name}"
        end
      end

      private

      attr_reader :url, :reference, :branch, :tag, :ref

      def checkout(git)
        reference&.then { git.checkout(_1) }
      end

      def reference_name
        branch || tag || ref || "main"
      end

      def short_ref
        return unless ref
        ref.match?(/^[a-z0-9]+$/) ? ref.slice(0, 7) : ref
      end
    end
  end
end
