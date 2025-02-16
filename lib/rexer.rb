module Rexer
  Config = Data.define(
    # The prefix of the command such as bundle install and bin/rails redmine:plugins:migrate.
    #
    # For example, if the command_prefix is set "docker compose exec -T app",
    # then bundle install will be executed as follows:
    #
    #   docker compose exec -T app bundle install
    #
    :command_prefix
  )

  class << self
    attr_accessor :verbosity

    def definition_file
      ".extensions.rb"
    end

    def definition_lock_file
      ".extensions.lock"
    end

    def redmine_root_dir
      if block_given?
        Dir.chdir(Definition.dir) { yield }
      else
        Definition.dir
      end
    end

    def config
      @config ||= Config.new(command_prefix: ENV["REXER_COMMAND_PREFIX"])
    end
  end
end

require "active_support"
require "pathname"
require "zeitwerk"

loader = Zeitwerk::Loader.for_gem
loader.setup
