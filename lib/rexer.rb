module Rexer
  def self.definition_file
    ".extensions.rb"
  end

  def self.definition_lock_file
    ".extensions.lock"
  end
end

require "pathname"
require "zeitwerk"

loader = Zeitwerk::Loader.for_gem
loader.setup
loader.eager_load
