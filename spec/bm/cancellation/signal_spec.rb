# frozen_string_literal: true

require 'bm/cancellation'

RSpec.describe BM::Cancellation::Signal do
  subject(:signal) { signal_control.cancellation }

  let(:signal_control) { BM::Cancellation.signal('Test') }
  let(:control) { signal_control.control }

  describe 'when created by the factory' do
    it 'inherits from the base class' do
      expect(signal).to be_kind_of(BM::Cancellation)
    end

    it 'does not cancelled' do
      expect(signal).not_to be_cancelled
      expect(control).not_to be_cancelled
    end

    it 'destructs to an array' do
      signal, control = BM::Cancellation.signal('Test')
      expect(signal).to be_kind_of(described_class::Signal)
      expect(control).to be_kind_of(described_class::Control)
    end
  end

  describe '#cancelled?' do
    it 'returns the current state of a signal' do
      expect { control.cancel }.to change(signal, :cancelled?).from(false).to(true)
    end
  end

  describe '#check!' do
    it 'raises when the signal cancelled' do
      expect(signal.check!).to be_nil
      control.cancel
      expect { signal.check! }.to raise_error(BM::Cancellation::ExecutionCancelled, 'Execution [Test] cancelled')
    end
  end
end
