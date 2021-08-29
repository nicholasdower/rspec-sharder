require 'spec_helper.rb'

describe 'invalid_options' do
  context '--total-shards' do
    context 'when --total-shards is negative' do
      subject { bundle_exec('test-rspec-sharder --total-shards -1 2>&1') }

      let(:expected_output) do
        <<~EOF
          fatal: invalid value for --total-shards
        EOF
      end

      it 'returns expected output' do
        expect(subject).to start_with(expected_output)
      end

      it 'exits with expected status' do
        expect($?.exitstatus).to eq(1)
      end
    end

    context 'when --total-shards is zero' do
      subject { bundle_exec('test-rspec-sharder --total-shards 0 2>&1') }

      let(:expected_output) do
        <<~EOF
          fatal: invalid value for --total-shards
        EOF
      end

      it 'returns expected output' do
        expect(subject).to start_with(expected_output)
      end

      it 'exits with expected status' do
        expect($?.exitstatus).to eq(1)
      end
    end

    context 'when --total-shards is not a number' do
      subject { bundle_exec('test-rspec-sharder --total-shards a 2>&1') }

      let(:expected_output) do
        <<~EOF
          fatal: invalid value for --total-shards
        EOF
      end

      it 'returns expected output' do
        expect(subject).to start_with(expected_output)
      end

      it 'exits with expected status' do
        expect($?.exitstatus).to eq(1)
      end
    end
  end

  context '--shard' do
    context 'when --shard is negative' do
      subject { bundle_exec('test-rspec-sharder --total-shards 4 --shard -1 2>&1') }

      let(:expected_output) do
        <<~EOF
          fatal: invalid value for --shard
        EOF
      end

      it 'returns expected output' do
        expect(subject).to start_with(expected_output)
      end

      it 'exits with expected status' do
        expect($?.exitstatus).to eq(1)
      end
    end

    context 'when --shard is zero' do
      subject { bundle_exec('test-rspec-sharder --total-shards 4 --shard -0 2>&1') }

      let(:expected_output) do
        <<~EOF
          fatal: invalid value for --shard
        EOF
      end

      it 'returns expected output' do
        expect(subject).to start_with(expected_output)
      end

      it 'exits with expected status' do
        expect($?.exitstatus).to eq(1)
      end
    end

    context 'when --shard is not a number' do
      subject { bundle_exec('test-rspec-sharder --total-shards 4 --shard a 2>&1') }

      let(:expected_output) do
        <<~EOF
          fatal: invalid value for --shard
        EOF
      end

      it 'returns expected output' do
        expect(subject).to start_with(expected_output)
      end

      it 'exits with expected status' do
        expect($?.exitstatus).to eq(1)
      end
    end

    context 'when --shard is greater than --total-shards' do
      subject { bundle_exec('test-rspec-sharder --total-shards 4 --shard 5 2>&1') }

      let(:expected_output) do
        <<~EOF
          fatal: --shard may not be greater than --total-shards
        EOF
      end

      it 'returns expected output' do
        expect(subject).to start_with(expected_output)
      end

      it 'exits with expected status' do
        expect($?.exitstatus).to eq(1)
      end
    end
  end

  context 'when unknown option is specified' do
    subject { bundle_exec('test-rspec-sharder --foo 2>&1') }

    let(:expected_output) do
      <<~EOF
        fatal: invalid option: --foo
      EOF
    end

    it 'returns expected output' do
      expect(subject).to start_with(expected_output)
    end

    it 'exits with expected status' do
      expect($?.exitstatus).to eq(1)
    end
  end
end
