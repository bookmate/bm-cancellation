# frozen_string_literal: true

require 'bm/cancellation'

RSpec.describe BM::Cancellation::Cancel do
  subject(:cancel) { cancel_control[0] }

  let(:cancel_control) { BM::Cancellation.cancel('Test') }
  let(:control) { cancel_control[1] }

  describe 'when created by the factory' do
    it 'inherits from the base class' do
      expect(cancel).to be_kind_of(BM::Cancellation)
    end

    it 'does not cancelled' do
      expect(cancel).not_to be_cancelled
    end

    it 'destructs to an array' do
      cancel, control = BM::Cancellation.cancel('Test')
      expect(cancel).to be_kind_of(described_class)
      expect(control).to be_kind_of(BM::Cancellation::Control)
    end
  end

  describe '#cancelled?' do
    it 'returns the current state of a signal' do
      expect { control.done }.to change(cancel, :cancelled?).from(false).to(true)
    end
  end

  describe '#check!' do
    it 'raises when the cancellation cancelled' do
      expect(cancel.check!).to be_nil
      control.done
      expect { cancel.check! }.to raise_error(BM::Cancellation::ExecutionCancelled, 'Execution [Test] cancelled')
    end
  end
end
