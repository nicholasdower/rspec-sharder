# RSpec Sharder

```
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
    -h, --help                       Print this message.
    -t, --total-shards <num>         The total number of shards. Defaults to 1.
    -s, --shard <num>                The shard to run. Defaults to 1.
        --no-persist                 Don't save durations to .rspec-sharder-durations.
```
