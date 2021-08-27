require 'rspec/core'

module RSpec
  module Sharder
    def self.run(total_shards: nil, shard_num: nil, rspec_args: [])
      raise "fatal: invalid total shards: #{total_shards}" unless total_shards.is_a?(Integer) && total_shards > 0
      raise "fatal: invalid shard number: #{shard_num}" unless shard_num.is_a?(Integer) && shard_num > 0 && shard_num <= total_shards

      begin
        ::RSpec::Core::ConfigurationOptions.new(rspec_args).configure(::RSpec.configuration)

        return if ::RSpec.world.wants_to_quit

        ::RSpec.configuration.load_spec_files
      ensure
        ::RSpec.world.announce_filters
      end

      return ::RSpec.configuration.reporter.exit_early(::RSpec.configuration.failure_exit_code) if ::RSpec.world.wants_to_quit

      example_groups = example_groups_for_shard(total_shards, shard_num)
      example_count = ::RSpec.world.example_count(example_groups)

      ::RSpec.configuration.reporter.report(example_count) do |reporter|
        ::RSpec.configuration.with_suite_hooks do
          if example_count == 0 && ::RSpec.configuration.fail_if_no_examples
            return ::RSpec.configuration.failure_exit_code
          end

          group_results = example_groups.map do |example_group|
            example_group.run(reporter)
          end

          success = group_results.all?
          exit_code = success ? 0 : 1
          if ::RSpec.world.non_example_failure
            success = false
            exit_code = ::RSpec.configuration.failure_exit_code
          end
          persist_example_statuses
          exit_code
        end
      end
    end

    private

    def self.example_groups_for_shard(total_shards, shard_num)
      files = { }

      ::RSpec.world.ordered_example_groups.each do |example_group|
        file_path = example_group.metadata[:file_path]
        files[file_path] ||= 0
        files[file_path] += ::RSpec.world.example_count([example_group])
      end

      shards = (1..total_shards).map { { example_count: 0, file_paths: [] } }

      # First sort by example count to ensure large files are distributed evenly.
      # Next, sort by path to ensure each shard generates the shard lists deterministically.
      # Note that files is a map, sorting it turns it into an array of arrays.
      files = files.sort_by { |file_path, example_count| [example_count, file_path] }.reverse
      files.each do |file_path, example_count|
        shards.sort_by! { |shard| shard[:example_count] }
        shards[0][:file_paths] << file_path
        shards[0][:example_count] += example_count
      end

      shards.each_with_index do |shard, i|
        ::RSpec.configuration.output_stream.puts "Shard #{i + 1}, #{shard[:example_count]} example(s) in #{shard[:file_paths].size} file(s):"
        shard[:file_paths].each do |file_path|
          ::RSpec.configuration.output_stream.puts file_path
        end
        ::RSpec.configuration.output_stream.puts
      end

      shard_file_paths = shards[shard_num - 1][:file_paths]

      ::RSpec.world.ordered_example_groups.select do |example_group|
        shard_file_paths.include?(example_group.metadata[:file_path])
      end
    end

    def self.persist_example_statuses
      return if ::RSpec.configuration.dry_run
      return unless (path = ::RSpec.configuration.example_status_persistence_file_path)

      ::RSpec::Core::ExampleStatusPersister.persist(::RSpec.world.all_examples, path)
    rescue SystemCallError => e
      ::RSpec.configuration.error_stream.puts "warning: failed to write results to #{path}"
    end
  end
end
