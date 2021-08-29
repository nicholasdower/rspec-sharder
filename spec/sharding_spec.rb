require 'spec_helper.rb'

describe 'sharding' do
  before do
    create_spec(
      'large_spec.rb',
      <<~RUBY
        describe 'large', duration: 5000 do
          it 'large' do
            expect(1).to eq(1)
          end
        end
      RUBY
    )
    create_spec(
      'small_spec.rb',
      <<~RUBY
        describe 'small', duration: 1000 do
          it 'small' do
            expect(1).to eq(1)
          end
        end
      RUBY
    )
    create_spec(
      'other_small_spec.rb',
      <<~RUBY
        describe 'other small', duration: 1000 do
          it 'other small' do
            expect(1).to eq(1)
          end
        end
      RUBY
    )
  end

  context 'when no durations file exists' do
    context 'when shard 1 of 2 is executed' do
      subject { bundle_exec('test-rspec-sharder --total-shards 2 --shard 1 -- --format documentation test_specs 2>&1') }

      let(:expected_output) do
        <<~EOF
          warning: 3 file(s) in not found in .rspec-sharder-durations, consider regenerating

          Shard 1 (Files: 2, Duration: 2 seconds):
          ./test_specs/large_spec.rb
          ./test_specs/other_small_spec.rb

          Shard 2 (Files: 1, Duration: 1 second):
          ./test_specs/small_spec.rb

          large
            large

          other small
            other small

          Finished in 0 seconds (files took 0 seconds to load)
          2 examples, 0 failures

          Durations
          ./test_specs/large_spec.rb,5000
          ./test_specs/other_small_spec.rb,1000

          Expected total duration: 2 seconds
          Actual total duration:   6 seconds
          Diff:                    4 seconds

          Saving to .rspec-sharder-durations.
        EOF
      end

      it 'returns expected output' do
        expect(subject).to eq(expected_output)
      end

      it 'creates a durations file' do
        subject
        expect(File).to exist('.rspec-sharder-durations')
        expect(File.read('.rspec-sharder-durations')).to eq(
          <<~EOF
            # Generated by rspec-sharder on 1982-08-05 07:21:00 -0500. See `bundle exec rspec-sharder -h`.

            ./test_specs/large_spec.rb,5000
            ./test_specs/other_small_spec.rb,1000
          EOF
        )
      end
    end

    context 'when shard 2 of 2 is executed' do
      subject { bundle_exec('test-rspec-sharder --total-shards 2 --shard 2 -- --format documentation test_specs 2>&1') }

      let(:expected_output) do
        <<~EOF
          warning: 3 file(s) in not found in .rspec-sharder-durations, consider regenerating

          Shard 1 (Files: 2, Duration: 2 seconds):
          ./test_specs/large_spec.rb
          ./test_specs/other_small_spec.rb

          Shard 2 (Files: 1, Duration: 1 second):
          ./test_specs/small_spec.rb

          small
            small

          Finished in 0 seconds (files took 0 seconds to load)
          1 example, 0 failures

          Durations
          ./test_specs/small_spec.rb,1000

          Expected total duration: 1 second
          Actual total duration:   1 second
          Diff:                    0 seconds

          Saving to .rspec-sharder-durations.
        EOF
      end

      it 'returns expected output' do
        expect(subject).to eq(expected_output)
      end

      it 'creates a durations file' do
        subject
        expect(File).to exist('.rspec-sharder-durations')
        expect(File.read('.rspec-sharder-durations')).to eq(
          <<~EOF
            # Generated by rspec-sharder on 1982-08-05 07:21:00 -0500. See `bundle exec rspec-sharder -h`.

            ./test_specs/small_spec.rb,1000
          EOF
        )
      end
    end
  end

  context 'when a durations file exists' do
    before { create_durations_file(durations_file_contents) }

    let(:durations_file_contents) do
        <<~EOF
          # Generated by rspec-sharder on 1982-08-05 07:21:00 -0500. See `bundle exec rspec-sharder -h`.

          ./test_specs/large_spec.rb,6000
          ./test_specs/other_small_spec.rb,3000
          ./test_specs/small_spec.rb,3000
        EOF
    end

    context 'when shard 1 of 2 is executed' do
      subject { bundle_exec('test-rspec-sharder --total-shards 2 --shard 1 -- --format documentation test_specs 2>&1') }

      let(:expected_output) do
        <<~EOF
          Shard 1 (Files: 2, Duration: 6 seconds):
          ./test_specs/other_small_spec.rb
          ./test_specs/small_spec.rb

          Shard 2 (Files: 1, Duration: 6 seconds):
          ./test_specs/large_spec.rb

          other small
            other small

          small
            small

          Finished in 0 seconds (files took 0 seconds to load)
          2 examples, 0 failures

          Durations
          ./test_specs/other_small_spec.rb,1000
          ./test_specs/small_spec.rb,1000

          Expected total duration: 6 seconds
          Actual total duration:   2 seconds
          Diff:                    4 seconds

          Saving to .rspec-sharder-durations.
        EOF
      end

      it 'returns expected output' do
        expect(subject).to eq(expected_output)
      end

      it 'updates the durations file' do
        subject
        expect(File).to exist('.rspec-sharder-durations')
        expect(File.read('.rspec-sharder-durations')).to eq(
          <<~EOF
            # Generated by rspec-sharder on 1982-08-05 07:21:00 -0500. See `bundle exec rspec-sharder -h`.

            ./test_specs/other_small_spec.rb,1000
            ./test_specs/small_spec.rb,1000
          EOF
        )
      end
    end

    context 'when shard 2 of 2 is executed' do
      subject { bundle_exec('test-rspec-sharder --total-shards 2 --shard 2 -- --format documentation test_specs 2>&1') }

      let(:expected_output) do
        <<~EOF
          Shard 1 (Files: 2, Duration: 6 seconds):
          ./test_specs/other_small_spec.rb
          ./test_specs/small_spec.rb

          Shard 2 (Files: 1, Duration: 6 seconds):
          ./test_specs/large_spec.rb

          large
            large

          Finished in 0 seconds (files took 0 seconds to load)
          1 example, 0 failures

          Durations
          ./test_specs/large_spec.rb,5000

          Expected total duration: 6 seconds
          Actual total duration:   5 seconds
          Diff:                    1 second

          Saving to .rspec-sharder-durations.
        EOF
      end

      it 'returns expected output' do
        expect(subject).to eq(expected_output)
      end

      it 'updates the durations file' do
        subject
        expect(File).to exist('.rspec-sharder-durations')
        expect(File.read('.rspec-sharder-durations')).to eq(
          <<~EOF
            # Generated by rspec-sharder on 1982-08-05 07:21:00 -0500. See `bundle exec rspec-sharder -h`.

            ./test_specs/large_spec.rb,5000
          EOF
        )
      end
    end
  end
end