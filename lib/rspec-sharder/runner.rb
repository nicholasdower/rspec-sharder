require 'rspec/core'
require 'rspec-sharder/sharder'

module RSpec
  module Sharder
    module Runner
      def self.run(total_shards:, shard_num:, persist:, rspec_args:)
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

        begin
          shards = ::RSpec::Sharder.build_shards(total_shards)
        rescue ::RSpec::Sharder::ShardError => e
          ::RSpec.configuration.error_stream.puts e.message
          return ::RSpec.configuration.reporter.exit_early(::RSpec.configuration.failure_exit_code)
        end

        print_shards(shards)

        expected_total_duration = shards[shard_num - 1][:duration]

        shard_file_paths = shards[shard_num - 1][:file_paths]
        example_groups = ::RSpec.world.ordered_example_groups.select do |example_group|
          shard_file_paths.include?(example_group.metadata[:file_path])
        end
        example_count = ::RSpec.world.example_count(example_groups)

        new_durations = { }

        actual_total_duration = 0
        exit_code = ::RSpec.configuration.reporter.report(example_count) do |reporter|
          ::RSpec.configuration.with_suite_hooks do
            if example_count == 0 && ::RSpec.configuration.fail_if_no_examples
              return ::RSpec.configuration.failure_exit_code
            end

            group_results = example_groups.map do |example_group|
              result, duration = run_example_group(example_group, reporter)

              file_path = example_group.metadata[:file_path]
              actual_total_duration += duration
              new_durations[file_path] ||= 0
              new_durations[file_path] += duration

              result
            end

            success = group_results.all?
            exit_code = success ? 0 : 1
            if ::RSpec.world.non_example_failure
              success = false
              exit_code = ::RSpec.configuration.failure_exit_code
            end
            exit_code
          end
        end

        # Write results to .examples file.
        unless ::RSpec.configuration.dry_run
          persist_example_statuses(shard_file_paths)
        end

        if ::RSpec.configuration.dry_run
          if persist
            ::RSpec.configuration.output_stream.puts <<~EOF
              
              Dry run. Not saving to .rspec-sharder-durations.
            EOF
          end
        else
          if exit_code == 0
            # Print recorded durations and summary.
            ::RSpec.configuration.output_stream.puts 'Durations'

            new_durations.sort_by { |file_path, duration| file_path }.each do |file_path, duration|
              ::RSpec.configuration.output_stream.puts "#{file_path},#{duration}"
            end

            ::RSpec.configuration.output_stream.puts <<~EOF
              
              Expected total duration: #{pretty_duration(expected_total_duration)}
              Actual total duration:   #{pretty_duration(actual_total_duration)}
              Diff:                    #{pretty_duration((actual_total_duration - expected_total_duration).abs)}
            EOF

            if persist
              # Write durations to .rspec-sharder-durations.
              ::RSpec.configuration.output_stream.puts <<~EOF

                Saving to .rspec-sharder-durations.
              EOF

              persist_durations(new_durations)
            end
          elsif persist
            ::RSpec.configuration.output_stream.puts <<~EOF
              
              RSpec failed. Not saving to .rspec-sharder-durations.
            EOF
          end
        end

        exit_code
      end

      private

      def self.persist_example_statuses(file_paths)
        return unless (path = ::RSpec.configuration.example_status_persistence_file_path)

        examples = ::RSpec.world.all_examples.select do |example|
          file_paths.include?(example.metadata[:file_path])
        end
        ::RSpec::Core::ExampleStatusPersister.persist(examples, path)
      rescue SystemCallError => e
        ::RSpec.configuration.output_stream.puts "warning: failed to write results to #{path}"
      end

      def self.pretty_duration(duration_millis)
        duration_seconds = (duration_millis / 1000.0).round
        minutes = duration_seconds / 60
        seconds = duration_seconds % 60

        minutes_str = "#{minutes} minute#{minutes == 1 ? '' : 's'}"
        seconds_str = "#{seconds} second#{seconds == 1 ? '' : 's'}"

        if minutes == 0
          seconds_str
        else
          "#{minutes_str}, #{seconds_str}"
        end
      end

      def self.print_shards(shards)
        shards.each_with_index do |shard, i|
          ::RSpec.configuration.output_stream.puts(
            "Shard #{i + 1} (Files: #{shard[:file_paths].size}, Duration: #{pretty_duration(shard[:duration])}):"
          )
          shard[:file_paths].each do |file_path|
            ::RSpec.configuration.output_stream.puts file_path
          end
          ::RSpec.configuration.output_stream.puts unless i == shards.size - 1
        end
      end

      def self.persist_durations(durations)
        File.open(".rspec-sharder-durations", "w+") do |file|
          file.puts <<~EOF
            # Generated by rspec-sharder on #{Time.now.to_s}. See `bundle exec rspec-sharder -h`.
            
          EOF
          durations.sort_by { |file_path, duration| file_path }.each do |file_path, duration|
            file.puts "#{file_path},#{duration}"
          end
        end
      end

      def self.current_time_millis
        (Process.clock_gettime(Process::CLOCK_MONOTONIC) * 1000).to_i
      end

      def self.run_example_group(example_group, reporter)
        start_time = current_time_millis
        result = example_group.run(reporter)
        [result, (current_time_millis - start_time).to_i]
      end
    end
  end
end
