require "thor"
require "dotenv"

module Rexer
  class Cli < Thor
    def self.exit_on_failure? = true

    class_option :verbose, type: :boolean, aliases: "-v", desc: "Detailed output"
    class_option :quiet, type: :boolean, aliases: "-q", desc: "Minimal output"

    desc "install [ENV]", "Install the definitions in .extensions.rb for the specified environment"
    def install(env = "default")
      Commands::Install.new.call(env&.to_sym)
    end

    desc "uninstall", "Uninstall extensions for the currently installed environment based on the state in .extensions.lock and remove the lock file"
    def uninstall
      Commands::Uninstall.new.call
    end

    desc "switch [ENV]", "Uninstall extensions for the currently installed environment and install extensions for the specified environment"
    def switch(env = "default")
      Commands::Switch.new.call(env&.to_sym)
    end

    desc "update", "Update extensions for the currently installed environment to the latest version"
    def update
      Commands::Update.new.call
    end

    desc "state", "Show the current state of the installed extensions"
    def state
      Commands::State.new.call
    end

    desc "envs", "Show the list of defined environments in .extensions.rb"
    def envs
      Commands::Envs.new.call
    end

    desc "version", "Show Rexer version"
    def version
      puts Rexer::VERSION
    end

    def initialize(*)
      super
      Dotenv.load
      initialize_options
    end

    private

    def initialize_options
      ENV["VERBOSE"] = "1" if options[:verbose]

      verbosity_level = if options[:verbose]
        :debug
      elsif options[:quiet]
        :error
      else
        :info
      end
      Rexer.verbosity = Commands::Verbosity.new(verbosity_level)
    end
  end
end
