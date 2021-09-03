require 'rspec/core'

module RSpec
  module Sharder
    class ShardError < StandardError; end

    def self.load_recorded_durations
      durations = { }

      missing_files = 0

      if File.exist?('.rspec-sharder-durations')
        File.readlines('.rspec-sharder-durations').each_with_index do |line, index|
          line = line.strip

          if !line.start_with?('#') && !line.empty?
            parts = line.split(',')

            unless parts.length == 2
              raise ShardError.new("fatal: invalid .rspec-sharder-durations at line #{index + 1}")
            end

            file_path = parts[0].strip

            if file_path.empty?
              raise ShardError.new("fatal: invalid file path in .rspec-sharder-durations at line #{index + 1}")
            end

            unless File.exist?(file_path)
              missing_files += 1
            end

            begin
              duration = Integer(parts[1])
            rescue ArgumentError => e
              raise ShardError.new("fatal: invalid .rspec-sharder-durations at line #{index + 1}")
            end

            durations[file_path] = duration
          end
        end.compact

        if missing_files > 0
          ::RSpec.configuration.output_stream.puts <<~EOF
            warning: #{missing_files} file(s) in .rspec-sharder-durations do not exist, consider regenerating

          EOF
        end
      end

      durations
    end

    def self.build_shards(total_shards)
      durations = load_recorded_durations

      files = { }

      missing_files = 0
      ::RSpec.world.ordered_example_groups.each do |example_group|
        file_path = example_group.metadata[:file_path]
        files[file_path] ||= 0
        if durations[file_path]
          files[file_path] = durations[file_path]
        else
          missing_files += 1
          # Assume 1000 milliseconds per example.
          files[file_path] += ::RSpec.world.example_count([example_group]) * 1000
        end
      end

      if missing_files > 0
        ::RSpec.configuration.output_stream.puts <<~EOF
          warning: #{missing_files} file(s) in not found in .rspec-sharder-durations, consider regenerating

        EOF
      end

      shards = (1..total_shards).map { { duration: 0, file_paths: [] } }

      # First sort by duration to ensure large files are distributed evenly.
      # Next, sort by path to ensure shards are generated deterministically.
      # Note that files is a map, sorting it turns it into an array of arrays.
      files = files.sort_by { |file_path, duration| [duration, file_path] }.reverse
      files.each do |file_path, duration|
        shards.sort_by! { |shard| shard[:duration] }
        shards[0][:file_paths] << file_path
        shards[0][:duration] += duration
      end

      shards.each { |shard| shard[:file_paths].sort! }

      shards
    end
  end
end
