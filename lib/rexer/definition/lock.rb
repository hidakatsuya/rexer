module Rexer
  module Definition
    module Lock
      def self.file
        @file ||= Pathname.new(Rexer.definition_lock_file)
      end

      def self.load_data
        return nil unless file.exist?

        dsl = Dsl.new.tap { _1.instance_eval(file.read) }
        dsl.to_data
      end

      def self.create_file(env)
        dsl = <<~DSL
          lock version: "#{Rexer::VERSION}", env: :#{env}

          #{Definition.file.read}
        DSL
        file.write(dsl)
      end

      class Dsl < Definition::Dsl
        def lock(env:, version:)
          lock_state.update(env:, version:)
        end

        def to_data
          Definition::Data.new(@plugins, @themes, **lock_state)
        end

        private

        def lock_state
          @lock_state ||= {}
        end
      end
    end
  end
end
