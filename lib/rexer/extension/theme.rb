module Rexer
  module Extension
    module Theme
      def self.dir
        public_themes = Pathname.pwd.join("public", "themes")

        if public_themes.exist?
          # When Redmine version is v5.1 or older, public/themes is used.
          public_themes
        else
          Pathname.new("themes")
        end
      end
    end
  end
end
