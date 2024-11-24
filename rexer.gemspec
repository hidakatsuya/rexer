require_relative "lib/rexer/version"

Gem::Specification.new do |spec|
  spec.name = "rexer"
  spec.version = Rexer::VERSION
  spec.authors = ["Katsuya Hidaka"]
  spec.email = ["hidakatsuya@gmail.com"]

  spec.summary = "A command-line tool for managing Redmine Plugins and Themes"
  spec.description = "Rexer is a command-line tool for managing Redmine Extension (Plugin and Themes). It allows you to define extensions in a Ruby DSL and install, uninstall, update, and switch between different sets of the extensions."
  spec.homepage = "https://github.com/hidakatsuya/rexer"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.0.0"

  spec.metadata["source_code_uri"] = spec.homepage

  spec.files = Dir["lib/**/*", "bin/*", "LICENSE.txt", "README.md"]
  spec.bindir = "exe"
  spec.executables = ["rex"]
  spec.require_paths = ["lib"]

  spec.add_dependency "thor", "~> 1.3"
  spec.add_dependency "git", "~> 2.1"
  spec.add_dependency "zeitwerk", "~> 2.6"
  spec.add_dependency "wisper", "~> 3.0"
  spec.add_dependency "paint", "~> 2.3"
  spec.add_dependency "dotenv", "~> 3.1"
  spec.add_dependency "activesupport", ">= 7.0"
end
