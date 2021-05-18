# frozen_string_literal: true

require 'bm/cancellation'

RSpec.describe BM::Cancellation::Signal do
  subject(:signal) { control.cancellation }

  let(:control) { BM::Cancellation.new }

  describe 'a control handler' do
    it 'converts to proc' do
      expect { [1].each(&control) }.to change(signal, :cancelled?).to(true)
    end
  end

  describe '#cancelled?' do
    it 'returns the current state of a cancellation' do
      expect { control.done }.to change(signal, :cancelled?).from(false).to(true)
    end
  end

  describe '#check!' do
    let(:cancelled) { BM::Cancellation::ExecutionCancelled }

    it 'raises when a cancellation cancelled' do
      expect(signal.check!).to be_nil
      control.done
      expect { signal.check! }.to raise_error(cancelled, 'Execution cancelled by signal')
    end
  end

  describe '#expires_after' do
    it 'returns a time' do
      3.times do
        expect(signal.expires_after).to eq(BM::Cancellation::EXPIRES_AFTER_MAX)
        sleep 0.1
      end
    end
  end

  describe '#reason' do
    it 'returns a constant string' do
      expect(signal.reason).to eq('Execution cancelled by signal')
    end
  end

  it_behaves_like 'when a cancellation has created by the factory'
  it_behaves_like 'combines into an Either'
  it_behaves_like 'combines with a timeout'
  it_behaves_like 'combines with a signal'
end
