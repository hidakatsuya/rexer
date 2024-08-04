require "bundler/gem_tasks"
require "rake/testtask"
require "standard/rake"

Rake::TestTask.new(:test) do |t|
  t.libs << "test"
  t.libs << "lib"
  t.test_files = FileList["test/**/*_test.rb"]
  t.warning = false
end

task default: %i[test standard]

namespace :rexer do
  namespace :test do
    desc "Build the integration test image"
    task :build_integration_test_image do
      system "docker build -f test/integration/Dockerfile -t rexer-test .", exception: true
    end
  end
end
