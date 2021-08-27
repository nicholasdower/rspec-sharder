# RSpec Sharder

```
Groups specs into shards, ensuring that each shard has a similar number of total
examples, and runs the specified shard.

To install, add the following to your Gemfile:

  gem 'rspec-sharder'

Usage: bundle exec rspec-sharder --total-shards <num> --shard-num <num> -- [rspec-args...]

Options:
    -h, --help                       Print this message.
    -t, --total-shards <num>         Required. The total number of shards
    -n, --shard-num <num>            Required. The shard to run.
```
