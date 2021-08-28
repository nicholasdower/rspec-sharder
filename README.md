# RSpec Sharder

```
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
    -h, --help                       Print this message.
    -t, --total-shards <num>         The total number of shards. Defaults to 1.
    -s, --shard <num>                The shard to run. Defaults to 1.
    -p, --persist                    Save durations to .spec_durations.
```
