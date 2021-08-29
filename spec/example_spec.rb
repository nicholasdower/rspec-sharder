describe 'rspec-sharder' do
  it 'returns expected output' do
    actual = `bundle exec spec/rspec-sharder -- --format d spec/support/`

    expected = <<~EOF
      warning: recorded duration not found for ./spec/support/example_spec.rb

      Shard 1 (Files: 1, Duration: 1 second):
      ./spec/support/example_spec.rb

      foo
        fam

      Finished in 0 seconds (files took 0 seconds to load)
      1 example, 0 failures

      Durations
      ./spec/support/example_spec.rb,5000

      Expected total duration: 1 second
      Actual total duration:   5 seconds
      Diff:                    4 seconds

      Saving to .rspec-sharder-durations.
    EOF

    expect(actual).to eq(expected)
  end
end
