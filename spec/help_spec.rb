require 'spec_helper.rb'

describe 'help' do
  context '--help' do
    subject { bundle_exec('test-rspec-sharder --help 2>&1') }

    let(:expected_output) do
      <<~EOF
        Groups specs into shards, ensuring that each shard has a similar size, and runs
      EOF
    end

    it 'returns expected output' do
      expect(subject).to start_with(expected_output)
    end

    it 'exits with expected status' do
      expect($?.exitstatus).to eq(0)
    end
  end

  context '-h' do
    subject { bundle_exec('test-rspec-sharder -h 2>&1') }

    let(:expected_output) do
      <<~EOF
        Groups specs into shards, ensuring that each shard has a similar size, and runs
      EOF
    end

    it 'returns expected output' do
      expect(subject).to start_with(expected_output)
    end

    it 'exits with expected status' do
      expect($?.exitstatus).to eq(0)
    end
  end
end
