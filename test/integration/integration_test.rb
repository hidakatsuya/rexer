require "integration/integration_helper"

class IntegrationTest < Test::Unit::TestCase
  include IntegrationHelper

  setup do
    docker_setup
  end

  teardown do
    docker_stop
  end

  test "rex version, install, uninstall, state and envs" do
    result = docker_exec("rex version")
    assert_equal Rexer::VERSION, result.output_str

    docker_exec("rex state").then do |result|
      assert_true result.success?
      assert_equal "No lock file found", result.output_str
    end

    docker_exec("rex uninstall -q").then do |result|
      assert_true result.success?
      assert_equal "No lock file found", result.output_str
    end

    docker_exec("rex envs").then do |result|
      assert_true result.success?
      assert_equal [
        "default",
        "  theme_a (/git-server-repos/theme_a.git)",
        "  plugin_a (/git-server-repos/plugin_a.git@HEAD)",
        "",
        "env1",
        "  plugin_a (/git-server-repos/plugin_a.git@v0.1.0)",
        "",
        "env2",
        "  theme_a (/git-server-repos/theme_a.git@master)",
        "  plugin_a (/git-server-repos/plugin_a.git@master)",
        "",
        "env3",
        "  theme_a (/git-server-repos/theme_a.git)",
        "  plugin_a (/git-server-repos/plugin_a.git@stable)",
        "",
        "env4",
        "  plugin_a (/git-server-repos/plugin_a.git@HEAD)",
        "",
        "env5",
        "  plugin_b (/git-server-repos/plugin_b.git@#{plugin_b_head_sha.slice(0, 7)})"
      ], result.output
    end

    docker_exec("rex install -q").then do |result|
      assert_true result.success?
      assert_equal [
        "Rexer: #{Rexer::VERSION}",
        "Env: default",
        "",
        "Themes:",
        " * theme_a (/git-server-repos/theme_a.git@master)",
        "",
        "Plugins:",
        " * plugin_a (/git-server-repos/plugin_a.git@HEAD)"
      ], result.output
    end

    docker_exec("ls plugins").then do |result|
      assert_equal "plugin_a", result.output.last
    end

    docker_exec("ls themes").then do |result|
      assert_includes result.output.last, "theme_a"
    end

    docker_exec("bundle show | grep prawn").then do |result|
      assert_true result.success?
    end

    docker_exec(%!bin/rails r "puts ActiveRecord::Base.connection.table_exists?('hellos')"!).then do |result|
      assert_equal "true", result.output_str
    end

    docker_exec("rex uninstall -q").then do |result|
      assert_true result.success?
      assert_equal "", result.output_str
    end

    docker_exec("ls plugins").then do |result|
      assert_equal ["README"], result.output
    end

    docker_exec("ls themes").then do |result|
      assert_equal %w[README], result.output
    end

    docker_exec(%!bin/rails r "puts ActiveRecord::Base.connection.table_exists?('hellos')"!).then do |result|
      assert_equal "false", result.output_str
    end

    docker_exec("rex state").then do |result|
      assert_equal "No lock file found", result.output_str
    end
  end

  test "rex switch" do
    docker_exec("rex switch -q").then do |result|
      assert_true result.success?
      assert_equal "No lock file found", result.output_str
    end

    docker_exec("rex install env1 -q").then do |result|
      assert_true result.success?
      assert_equal [
        "Rexer: #{Rexer::VERSION}",
        "Env: env1",
        "",
        "Plugins:",
        " * plugin_a (/git-server-repos/plugin_a.git@v0.1.0)"
      ], result.output
    end

    docker_exec("rex switch env2 -q").then do |result|
      assert_true result.success?
      assert_equal [
        "Rexer: #{Rexer::VERSION}",
        "Env: env2",
        "",
        "Themes:",
        " * theme_a (/git-server-repos/theme_a.git@master)",
        "",
        "Plugins:",
        " * plugin_a (/git-server-repos/plugin_a.git@master)"
      ], result.output
    end

    docker_exec("rex switch env4 -q").then do |result|
      assert_true result.success?
      assert_equal [
        "Rexer: #{Rexer::VERSION}",
        "Env: env4",
        "",
        "Plugins:",
        " * plugin_a (/git-server-repos/plugin_a.git@HEAD)"
      ], result.output
    end
  end

  test "rex update" do
    # env3 (branch or default branch)
    docker_exec("rex install env3 -q").then do |result|
      assert_true result.success?
    end

    docker_exec("/update.sh add_readme_to_env3")

    docker_exec("rex update").then do |result|
      assert_true result.success?
      assert_includes result.output_str, "plugin_a ... #{Paint["done", :green]}"
      assert_includes result.output_str, "theme_a ... #{Paint["done", :green]}"
    end

    docker_exec("cat /redmine/plugins/plugin_a/README").then do |result|
      assert_equal "update", result.output_str
    end

    docker_exec("cat themes/theme_a/README").then do |result|
      assert_equal "update", result.output_str
    end

    # rex update [extensions...]
    docker_exec("rex update plugin_a theme_a").then do |result|
      assert_true result.success?
      assert_includes result.output_str, "plugin_a ... #{Paint["done", :green]}"
      assert_includes result.output_str, "theme_a ... #{Paint["done", :green]}"
    end

    docker_exec("rex update theme_a").then do |result|
      assert_true result.success?
      assert_includes result.output_str, "theme_a ... #{Paint["done", :green]}"
      assert_not_includes result.output_str, "plugin_a"
    end

    # env1 (tag)
    docker_exec("rex switch env1 -q").then do |result|
      assert_true result.success?
    end

    docker_exec("rex update").then do |result|
      assert_true result.success?
      assert_includes result.output_str, "plugin_a ... #{Paint["skipped (Not updatable)", :yellow]}"
    end

    # env4 (ref)
    docker_exec("rex switch env4 -q").then do |result|
      assert_true result.success?
    end

    docker_exec("rex update").then do |result|
      assert_true result.success?
      assert_includes result.output_str, "plugin_a ... #{Paint["skipped (Not updatable)", :yellow]}"
    end
  end

  test "hooks" do
    docker_exec("rex install env3 -q").then do |result|
      assert_true result.success?
      assert_includes result.output, "plugin_a installed"
      assert_includes result.output, "theme_a installed"
    end

    docker_exec("rex update -q").then do |result|
      assert_true result.success?
      assert_not_includes result.output, "plugin_a updated"
      assert_not_includes result.output, "theme_a updated"
    end

    docker_exec("rex uninstall -q").then do |result|
      assert_true result.success?
      assert_includes result.output, "plugin_a uninstalled"
      assert_includes result.output, "theme_a uninstalled"
    end
  end

  test "rex install with adding/removing other plugin and changing the source" do
    docker_exec("/update.sh install_test:set_extensions_rb").then do |result|
      assert_true result.success?
    end

    docker_exec("rex install -q").then do |result|
      assert_true result.success?
      assert_equal [
        "Rexer: #{Rexer::VERSION}",
        "Env: default",
        "",
        "Plugins:",
        " * plugin_a (/git-server-repos/plugin_a.git@master)"
      ], result.output
    end

    docker_exec("/update.sh install_test:set_extensions_rb_with_adding_plugin_b")

    docker_exec("rex install -q").then do |result|
      assert_true result.success?
      assert_equal [
        "Rexer: #{Rexer::VERSION}",
        "Env: default",
        "",
        "Plugins:",
        " * plugin_a (/git-server-repos/plugin_a.git@master)",
        " * plugin_b (/git-server-repos/plugin_b.git@master)"
      ], result.output
    end

    docker_exec("/update.sh install_test:set_extensions_rb_with_changing_source_of_plugin_a")

    docker_exec("rex install -q").then do |result|
      assert_true result.success?
      assert_equal [
        "Rexer: #{Rexer::VERSION}",
        "Env: default",
        "",
        "Plugins:",
        " * plugin_a (/git-server-repos/plugin_a.git@v0.1.0)",
        " * plugin_b (/git-server-repos/plugin_b.git@master)"
      ], result.output
    end

    docker_exec("/update.sh install_test:set_extensions_rb")

    docker_exec("rex install -q").then do |result|
      assert_true result.success?
      assert_equal [
        "Rexer: #{Rexer::VERSION}",
        "Env: default",
        "",
        "Plugins:",
        " * plugin_a (/git-server-repos/plugin_a.git@master)"
      ], result.output
    end
  end

  test "rex init" do
    docker_exec("rex init").then do |result|
      assert_false result.success?
      assert_equal Paint[".extensions.rb already exists", :red], result.output_str
    end

    docker_exec("rm .extensions.rb", raise_on_error: true)

    docker_exec("rex init").then do |result|
      assert_true result.success?
      assert_includes result.output_str, "created"
    end

    docker_exec("cat .extensions.rb").then do |result|
      assert_true result.success?
      assert_includes result.output_str, "Define themes and plugins you want to use in your Redmine here"
    end
  end

  test "rex reinstall" do
    docker_exec("rex reinstall plugin_a").then do |result|
      assert_true result.success?
      assert_equal "No lock file found", result.output_str
    end

    docker_exec("rex install env2").then do |result|
      assert_true result.success?
    end

    docker_exec("rex reinstall plugin_x").then do |result|
      assert_true result.success?
      assert_equal "plugin_x is not installed", result.output_str
    end

    docker_exec("rex reinstall plugin_a").then do |result|
      assert_true result.success?
      assert_includes result.output_str, "Uninstall plugin_a"
      assert_includes result.output_str, "Install plugin_a"
    end

    docker_exec("rex state").then do |result|
      assert_equal [
        "Rexer: #{Rexer::VERSION}",
        "Env: env2",
        "",
        "Themes:",
        " * theme_a (/git-server-repos/theme_a.git@master)",
        "",
        "Plugins:",
        " * plugin_a (/git-server-repos/plugin_a.git@master)"
      ], result.output
    end
  end

  test "in a subdirectory" do
    docker_exec("cd plugins", "rex envs").then do |result|
      assert_true result.success?
      assert_includes result.output_str, "default"
    end

    docker_exec("cd plugins", "rex state").then do |result|
      assert_true result.success?
      assert_equal "No lock file found", result.output_str
    end

    docker_exec("cd plugins", "rex install -q").then do |result|
      assert_true result.success?
      assert_equal [
        "Rexer: #{Rexer::VERSION}",
        "Env: default",
        "",
        "Themes:",
        " * theme_a (/git-server-repos/theme_a.git@master)",
        "",
        "Plugins:",
        " * plugin_a (/git-server-repos/plugin_a.git@HEAD)"
      ], result.output
    end

    docker_exec("cd plugins", "rex switch env3 -q").then do |result|
      assert_true result.success?
      assert_includes result.output, "plugin_a installed"
      assert_includes result.output, "theme_a installed"
    end

    docker_exec("cd plugins", "rex uninstall -q").then do |result|
      assert_true result.success?
      assert_includes result.output, "plugin_a uninstalled"
      assert_includes result.output, "theme_a uninstalled"
    end
  end

  def plugin_b_head_sha
    docker_exec("git -C /git-local-repos/plugin_b rev-parse HEAD").output_str.strip
  end
end
