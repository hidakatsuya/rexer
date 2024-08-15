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

    docker_exec("rex uninstall").then do |result|
      assert_true result.success?
      assert_equal "No lock file found", result.output_str
    end

    docker_exec("rex envs").then do |result|
      assert_true result.success?
      assert_equal %w[default env1 env2 env3], result.output
    end

    docker_exec("rex install").then do |result|
      assert_true result.success?
      assert_equal [
        "Rexer: #{Rexer::VERSION}",
        "Env: default",
        "",
        "Themes:",
        " * theme_a (master)",
        "",
        "Plugins:",
        " * plugin_a (master)"
      ], result.output
    end

    docker_exec("ls plugins").then do |result|
      assert_equal "plugin_a", result.output.last
    end

    docker_exec("ls #{theme_dir}").then do |result|
      assert_includes result.output.last, "theme_a"
    end

    docker_exec("bin/rails r 'puts Hello.table_name'").then do |result|
      assert_equal "hellos", result.output_str
    end

    docker_exec("rex uninstall").then do |result|
      assert_true result.success?
      assert_equal "", result.output_str
    end

    docker_exec("ls plugins").then do |result|
      assert_equal ["README"], result.output
    end

    docker_exec("ls #{theme_dir}").then do |result|
      expected_files = legacy_theme_dir? ? %w[README alternate classic] : %w[README]
      assert_equal expected_files, result.output
    end

    docker_exec("rex state").then do |result|
      assert_equal "No lock file found", result.output_str
    end
  end

  test "rex switch" do
    docker_exec("rex switch").then do |result|
      assert_true result.success?
      assert_equal "No lock file found", result.output_str
    end

    docker_exec("rex install env1").then do |result|
      assert_true result.success?
      assert_equal [
        "Rexer: #{Rexer::VERSION}",
        "Env: env1",
        "",
        "Plugins:",
        " * plugin_a (v0.1.0)"
      ], result.output
    end

    docker_exec("rex switch env2").then do |result|
      assert_true result.success?
      assert_equal [
        "Rexer: #{Rexer::VERSION}",
        "Env: env2",
        "",
        "Themes:",
        " * theme_a (master)",
        "",
        "Plugins:",
        " * plugin_a (master)"
      ], result.output
    end
  end

  test "rex update and hooks" do
    docker_exec("rex install env3").then do |result|
      assert_true result.success?
      assert_includes result.output, "plugin_a installed"
      assert_includes result.output, "theme_a installed"
    end

    docker_exec("/update.sh add_readme_to_env3")

    docker_exec("rex update").then do |result|
      assert_true result.success?
      assert_equal "", result.output_str
    end

    docker_exec("cat /redmine/plugins/plugin_a/README").then do |result|
      assert_equal "update", result.output_str
    end

    docker_exec("cat #{theme_dir}/theme_a/README").then do |result|
      assert_equal "update", result.output_str
    end

    docker_exec("rex uninstall").then do |result|
      assert_true result.success?
      assert_includes result.output, "plugin_a uninstalled"
      assert_includes result.output, "theme_a uninstalled"
    end
  end

  test "rex install with adding/removing other plugin and changing the source" do
    docker_exec("cat /redmine/.extensions.rb").then do |result|
      puts "x1"
      puts result.output_str
    end

    docker_exec("/update.sh install_test:set_extensions_rb").then do |result|
      puts result.error
      assert_true result.success?
    end

    docker_exec("cat /redmine/.extensions.rb").then do |result|
      puts "x2"
      puts result.output_str
    end

    docker_exec("rex install").then do |result|
      assert_true result.success?
      assert_equal [
        "Rexer: #{Rexer::VERSION}",
        "Env: default",
        "",
        "Plugins:",
        " * plugin_a (master)"
      ], result.output
    end

    docker_exec("/update.sh install_test:set_extensions_rb_with_adding_plugin_b")

    docker_exec("rex install").then do |result|
      assert_true result.success?
      assert_equal [
        "Rexer: #{Rexer::VERSION}",
        "Env: default",
        "",
        "Plugins:",
        " * plugin_a (master)",
        " * plugin_b (master)"
      ], result.output
    end

    docker_exec("/update.sh install_test:set_extensions_rb_with_changing_source_of_plugin_a")

    docker_exec("rex install").then do |result|
      assert_true result.success?
      assert_equal [
        "Rexer: #{Rexer::VERSION}",
        "Env: default",
        "",
        "Plugins:",
        " * plugin_a (v0.1.0)",
        " * plugin_b (master)"
      ], result.output
    end

    docker_exec("/update.sh install_test:set_extensions_rb")

    docker_exec("rex install").then do |result|
      assert_true result.success?
      assert_equal [
        "Rexer: #{Rexer::VERSION}",
        "Env: default",
        "",
        "Plugins:",
        " * plugin_a (master)"
      ], result.output
    end
  end
end
