module Rexer
  module Commands
    class Init
      def call
        unless redmine_root_dir?
          puts Paint["Please run in the Redmine root directory.", :red]
          exit 1
        end

        definition_file = Pathname.new(Rexer.definition_file)

        if definition_file.exist?
          puts Paint["#{definition_file.basename} already exists", :red]
          exit 1
        end

        definition_file.write(template)

        puts Paint["#{definition_file.expand_path} created", :green]
      end

      private

      def template
        <<~TEMPLATE
          # Define themes and plugins you want to use in your Redmine here.
          #
          # Syntax for defining themes and plugins is as follows.
          # For theme_id and plugin_id, specify the name of the installation directory.
          #
          #   theme :theme_a_id, github: { repo: "repo/theme_a" }
          #   theme :theme_b_id, github: { repo: "repo/theme_b", ref: "abcdefghi" }
          #   plugin :plugin_a_id, github: { repo: "repo/plugin_a", tag: "v1.0.0" }
          #   plugin :plugin_b_id, git: { url: "https://github.com/repo/plugin_b.git", branch: "stable" }
          #
          # Then, run `rex install` to install these themes and plugins.
          #
          # For more usage, see https://github.com/hidakatsuya/rexer.

        TEMPLATE
      end

      def redmine_root_dir?
        Pathname.new("README.rdoc").then { _1.exist? && _1.read.include?("Redmine") }
      end
    end
  end
end
