require 'spec_helper.rb'

describe '--no-persist' do
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

  subject { bundle_exec('test-rspec-sharder --no-persist -- --format documentation test_specs 2>&1') }

  context 'when no durations file exists' do
    let(:expected_output) do
      <<~EOF
        warning: 1 file(s) in not found in .rspec-sharder-durations, consider regenerating

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
      EOF
    end

    it 'returns expected output' do
      expect(subject).to eq(expected_output)
    end

    it 'does not create a durations file' do
      subject
      expect(File).not_to exist('.rspec-sharder-durations')
    end
  end

  context 'when a durations file exists' do
    before { create_durations_file(durations_file_contents) }

    let(:durations_file_contents) do
        <<~EOF
          # Generated by rspec-sharder on 1960-01-01 00:00:00 -0500. See `bundle exec rspec-sharder -h`.

          ./test_specs/example_spec.rb,2000
        EOF
    end

    let(:expected_output) do
      <<~EOF
        Shard 1 (Files: 1, Duration: 2 seconds):
        ./test_specs/example_spec.rb

        foo
          fam

        Finished in 0 seconds (files took 0 seconds to load)
        1 example, 0 failures

        Durations
        ./test_specs/example_spec.rb,5000

        Expected total duration: 2 seconds
        Actual total duration:   5 seconds
        Diff:                    3 seconds
      EOF
    end

    it 'returns expected output' do
      expect(subject).to eq(expected_output)
    end

    it 'does not modify the durations file' do
      subject
      expect(File).to exist('.rspec-sharder-durations')
      expect(File.read('.rspec-sharder-durations')).to eq(durations_file_contents)
    end
  end
end
