require 'optparse'
require 'rspec-sharder'

def fail(message)
  warn message
  puts
  puts @parser.help
  exit 1
end

@total_shards = 1
@shard = 1
@persist = true

@parser = OptionParser.new do |opts|
  opts.banner = <<~EOF
    Groups specs into shards, ensuring that each shard has a similar size, and runs
    the specified shard.

    Shard size is determined by summing the saved durations for each spec file in
    the shard. Durations are saved in .rspec-sharder-durations. If a spec file is
    not found in .rspec-sharder-durations, the duration is estimated based on the
    number of examples in the spec file.

    .rspec-sharder-durations is generated after each successful run, but only for
    the specs which were run as part of the specified shard. Before first use,
    generate .rspec-sharder-durations for all specs by executing with the default
    option of 1 total shards:

      bundle exec rspec-sharder -- [<rspec-args...>]

    Commit .rspec-sharder-durations file to your version control.

    Next, configure 2 or more CI jobs to execute separate shards like:

      bundle exec rspec-sharder --total-shards 4 --shard 1 -- [<rspec-args...>]
      bundle exec rspec-sharder --total-shards 4 --shard 2 -- [<rspec-args...>]
      bundle exec rspec-sharder --total-shards 4 --shard 3 -- [<rspec-args...>]
      bundle exec rspec-sharder --total-shards 4 --shard 4 -- [<rspec-args...>]

    Finally, set up some job or process to periodically pull .rspec-sharder-durations
    files from CI, combine them, and commit them to source control. This will ensure
    you pick up updated durations for any new or changed files.

    Usage: bundle exec rspec-sharder [--total-shards <num> [--shard <num>]] [--no-persist] -- [<rspec-args...>]

    Options:
  EOF

  opts.on('-h', '--help', "Print this message.") do
    puts opts
    exit
  end

  opts.on('-t', '--total-shards <num>', 'The total number of shards. Defaults to 1.') do |total_shards|
    begin
      @total_shards = Integer(total_shards)
    rescue ArgumentError
      fail('fatal: invalid value for --total-shards')
    end
  end

  opts.on('-s', '--shard <num>', 'The shard to run. Defaults to 1.') do |shard|
    begin
      @shard = Integer(shard)
    rescue ArgumentError
      fail('fatal: invalid value for --shard')
    end
  end

  opts.on('--no-persist', "Don't save durations to .rspec-sharder-durations.") do
    @persist = false
  end
end

begin
  @parser.parse!
rescue StandardError => e
  fail("fatal: #{e.message}")
end

fail('fatal: invalid value for --total-shards') unless @total_shards > 0
fail('fatal: invalid value for --shard') unless @shard > 0
fail('fatal: --shard may not be greater than --total-shards') unless @shard <= @total_shards

exit RSpec::Sharder.run(total_shards: @total_shards, shard_num: @shard, persist: @persist, rspec_args: ARGV)
