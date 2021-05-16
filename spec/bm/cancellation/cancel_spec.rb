# frozen_string_literal: true

require 'bm/cancellation'

RSpec.describe BM::Cancellation::Cancel do
  subject(:cancel) { cancel_control[0] }

  let(:cancel_control) { BM::Cancellation.cancel('Test') }
  let(:control) { cancel_control[1] }

  context 'when created' do
    it 'destructs to an array' do
      cancel, control = BM::Cancellation.cancel('Test')
      expect(cancel).to be_kind_of(described_class)
      expect(control).to be_frozen.and be_kind_of(BM::Cancellation::Control)
    end
  end

  describe 'a control handler' do
    it 'converts to proc' do
      expect { [1].each(&control) }.to change(cancel, :cancelled?).to(true)
    end
  end

  describe '#cancelled?' do
    it 'returns the current state of a cancellation' do
      expect { control.done }.to change(cancel, :cancelled?).from(false).to(true)
    end
  end

  describe '#check!' do
    let(:cancelled) { BM::Cancellation::ExecutionCancelled }

    it 'raises when a cancellation cancelled' do
      expect(cancel.check!).to be_nil
      control.done
      expect { cancel.check! }.to raise_error(cancelled, 'Execution [Test] cancelled')
    end
  end

  describe '#expires_after' do
    it 'returns a time' do
      expect(cancel.expires_after).to eq(BM::Cancellation::EXPIRES_AFTER_MAX)
      expect(cancel.expires_after).to eq(BM::Cancellation::EXPIRES_AFTER_MAX)
    end
  end

  it_behaves_like 'when a cancellation has created by the factory', name: 'Test'
  it_behaves_like 'combines into an Either'
  it_behaves_like 'combines with a timeout'
end
