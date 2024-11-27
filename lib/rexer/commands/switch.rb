module Rexer
  module Commands
    class Switch
      def initialize
        @lock_definition = Definition::Lock.load_data
      end

      def call(env)
        return if no_lock_file_found
        return if already_in(env)

        Uninstall.new.call
        Install.new.call(env)
      end

      private

      attr_reader :lock_definition

      def no_lock_file_found
        lock_definition.nil?.tap { |result|
          puts "No lock file found" if result
        }
      end

      def already_in(env)
        (lock_definition.env == env).tap do |result|
          puts "Already in #{env} environment" if result
        end
      end
    end
  end
end
