# RSpec Sharder

```
Groups specs into shards, ensuring that each shard has a similar size, and runs the
specified shard.

Shard size is determined by summing the recorded durations for each spec file in the
shard. Durations are found in .spec_durations.txt. If a spec file is not found in
.spec_durations.txt, the duration is estimated based on the number of examples in the
spec file.

.spec_durations.txt is generate/updated on each run, but only for the shard which was
actually executed. To generate durations for all shards simultaneously, run this
with the default options (1 shard total):

bundle exec rspec-sharder -- [<rspec-args...>]

Usage: bundle exec rspec-sharder [--total-shards <num> [--shard-num <num>]] -- [<rspec-args...>]

Options:
    -h, --help                       Print this message.
    -t, --total-shards <num>         Optional. The total number of shards. Defaults to 1.
    -n, --shard-num <num>            Optional. The shard to run. Defaults to 1.
```
