# frozen_string_literal: true

require 'bm/cancellation'

RSpec.describe BM::Cancellation::Control do
  subject(:control) { signal_control.control }

  let(:signal_control) { BM::Cancellation.signal('Test') }
  let(:signal) { signal_control.cancellation }

  describe '#cancel' do
    it 'cancels a signal' do
      expect do
        expect { control.cancel }.to change(control, :cancelled?).to(true)
      end.to change(signal, :cancelled?).to(true)
    end

    it 'returns true for 1st time and false for next times' do
      expect(control.cancel).to be_truthy
      3.times do
        expect(control.cancel).to be_falsey
      end
    end
  end
end
