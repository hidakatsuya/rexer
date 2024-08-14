require "bundler/gem_tasks"
require "rake/testtask"
require "standard/rake"

Rake::TestTask.new("test:integration") do |t|
  t.libs << "test"
  t.libs << "lib"
  t.test_files = FileList["test/integration/**/*_test.rb"]
  t.warning = false
end

task default: %i[test standard]

desc "Run all tests"
task test: %i[test:integration]

namespace :test do
  desc "Prepare to run integration tests"
  task :prepare_integration do
    ruby_version = ENV["RUBY_VERSION"] || "3.3"
    redmine_branch_name = ENV["REDMINE_BRANCH_NAME"] || "master"

    image_tag = "rexer-test:#{ruby_version}-#{redmine_branch_name}"

    system(<<~CMD, exception: true)
      docker build -f test/integration/Dockerfile \
        --build-arg RUBY_VERSION=#{ruby_version} \
        --build-arg REDMINE_BRANCH_NAME=#{redmine_branch_name} \
        -t #{image_tag} .
    CMD
  end
end
