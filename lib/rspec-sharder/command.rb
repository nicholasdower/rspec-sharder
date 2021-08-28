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
@persist = false

@parser = OptionParser.new do |opts|
  opts.banner = <<~EOF
    Groups specs into shards, ensuring that each shard has a similar size, and runs
    the specified shard.

    Shard size is determined by summing the saved durations for each spec file in
    the shard. Durations are saved in .spec_durations. If a spec file is not found
    in .spec_durations, the duration is estimated based on the number of examples in
    the spec file.

    .spec_durations is generate/updated after a successful run when --persist is
    specified, but only for the shard which was actually executed. To generate
    durations for all shards simultaneously, run with the default options of 1 total
    shards and --persist:

    bundle exec rspec-sharder --persist -- [<rspec-args...>]

    Usage: bundle exec rspec-sharder [--total-shards <num> [--shard <num>]] [--persist] -- [<rspec-args...>]

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

  opts.on('-p', '--persist', 'Save durations to .spec_durations.') do
    @persist = true
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

RSpec::Sharder.run(total_shards: @total_shards, shard_num: @shard, persist: @persist, rspec_args: ARGV)