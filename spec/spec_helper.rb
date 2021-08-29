require 'fileutils'

def create_spec(file_path, contents)
  Dir.chdir __dir__

  unless File.exists?('test_specs')
    Dir.mkdir 'test_specs'
  end

  file_path = "test_specs/#{file_path}"
  raise "spec already exists: #{file_path}" if File.exist?(file_path)

  File.open(file_path, 'w+') { |file| file.write(contents) }
end

def create_durations_file(contents)
  Dir.chdir __dir__

  raise '.rspec-sharder-durations already exists' if File.exist?('.rspec-sharder-durations')

  File.open('.rspec-sharder-durations', 'w+') { |file| file.write(contents) }
end

def bundle_exec(args)
  Dir.chdir __dir__
  `bundle exec #{args}`
end

RSpec.configure do |config|
  config.formatter = :documentation

  config.before(:each) do
    Dir.chdir __dir__
    FileUtils.remove_dir('test_specs', true)
    FileUtils.rm_f('.rspec-sharder-durations')
  end

  config.after(:each) do
    Dir.chdir __dir__
    FileUtils.remove_dir('test_specs', true)
    FileUtils.rm_f('.rspec-sharder-durations')
  end
end
