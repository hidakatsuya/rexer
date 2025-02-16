require "shellwords"

module Rexer
  module Commands
    class Edit
      def call
        definition_file = Definition.file

        if editor.to_s.empty?
          puts Paint["Please set your $VISUAL or $EDITOR environment variable.", :red]
          exit 1
        end

        edit_system_editor(definition_file.to_s)
      end

      private

      def editor
        ENV["VISUAL"].to_s.empty? ? ENV["EDITOR"] : ENV["VISUAL"]
      end

      def edit_system_editor(file_path)
        system(*Shellwords.split(editor), file_path)
      end
    end
  end
end
