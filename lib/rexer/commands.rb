module Rexer
  module Commands
    module ActionCallable
      def call_action(action_class, *init_args)
        progress_notifier = ProgressNotifier.new

        action = action_class.new(*init_args)
        action.subscribe(progress_notifier).call
      end
    end

    class Verbosity < Data.define(:current_level)
      LEVELS = %i[error info debug].freeze

      LEVELS.each do |level|
        define_method(:"#{level}?") { level == current_level }
      end

      def on?(level)
        LEVELS.index(current_level) >= LEVELS.index(level)
      end

      def on(level, &block)
        on?(level) ? block.call : nil
      end
    end

    class ProgressNotifier
      def started(process_title)
        Rexer.verbosity.on(:info) { print "#{process_title} ... " }
      end

      def completed
        Rexer.verbosity.on(:info) { puts "done." }
      end

      def processing(process_title)
        Rexer.verbosity.on(:debug) { puts process_title }
      end
    end
  end
end
