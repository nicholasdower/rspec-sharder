require 'spec_helper.rb'

describe 'rspec-sharder' do
  before do
    create_spec(
      'example_spec.rb',
      <<~RUBY
        describe 'foo', duration: 5000 do
          it 'fam' do
            expect(1).to eq(1)
          end
        end
      RUBY
    )
  end

  let(:actual) { run_rspec_sharder }
  let(:expected) do
    <<~EOF
      warning: recorded duration not found for ./test_specs/example_spec.rb

      Shard 1 (Files: 1, Duration: 1 second):
      ./test_specs/example_spec.rb

      foo
        fam

      Finished in 0 seconds (files took 0 seconds to load)
      1 example, 0 failures

      Durations
      ./test_specs/example_spec.rb,5000

      Expected total duration: 1 second
      Actual total duration:   5 seconds
      Diff:                    4 seconds

      Saving to .rspec-sharder-durations.
    EOF
  end

  it 'returns expected output' do
    expect(actual).to eq(expected)
  end
end
