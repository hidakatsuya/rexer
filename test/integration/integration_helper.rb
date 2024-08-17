require "test_helper"
require "open3"
require "rake"

ENV["VERBOSE"] = "1"
ENV["RUBY_VERSION"] ||= "3.3"
ENV["REDMINE_BRANCH_NAME"] ||= "master"

module IntegrationHelper
  Result = Data.define(:output_raw, :error_raw, :status_raw) do
    def output_str = output_raw.strip

    def output = output_str.split("\n")

    def error = error_raw.strip

    def success? = status_raw.success?
  end

  def image_name
    @image_name ||= "rexer-test:#{ENV["RUBY_VERSION"]}-#{ENV["REDMINE_BRANCH_NAME"]}"
  end

  def container_name = "rexer-test-container"

  def run_with_capture(command, raise: false)
    Result.new(*Open3.capture3(command)) do |result|
      raise result.error if raise && !result.success?
    end
  end

  def docker_setup
    docker_build
    docker_launch
    setup_rexer
  end

  def setup_rexer
    docker_exec("/setup_rexer.sh", raise: true)
  end

  def docker_build
    image_exists = run_with_capture("docker inspect #{image_name}", raise: true).success?

    system "rake rexer:test:build_integration_test_image", exception: true unless image_exists
  end

  def docker_launch
    run_with_capture(
      "docker run --rm -d -v rexer-redmine-bundle-cache:/redmine/vendor/cache -v $PWD:/rexer-src --name #{container_name} #{image_name}",
      raise: true
    )

    try = 0
    while `docker inspect -f {{.State.Running}} #{container_name}`.strip != "true"
      raise "Failed to start container" if try > 10
      try += 1
      sleep 1
    end
  end

  def docker_exec(*command, raise: false)
    run_with_capture("docker exec #{container_name} #{command.join(" && ")}", raise:)
  end

  def docker_stop
    run_with_capture("docker container stop -t 0 #{container_name} && docker container rm #{container_name}", raise: true)
  end

  def legacy_theme_dir?
    return @legacy_theme_dir if defined?(@legacy_theme_dir)
    @legacy_theme_dir = docker_exec("test -d /redmine/public/themes").success?
  end

  def theme_dir
    legacy_theme_dir? ? "/redmine/public/themes" : "/redmine/themes"
  end
end
