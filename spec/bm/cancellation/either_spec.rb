# frozen_string_literal: true

require 'bm/cancellation'

RSpec.describe BM::Cancellation::Either do
  subject(:either) { left | right }

  let(:cancel) { Struct.new(:cancel, :control).new(*BM::Cancellation.cancel('Left')) }
  let(:left) { cancel.cancel }
  let(:control) { cancel.control }
  let(:right) { BM::Cancellation.timeout('Right', seconds: timeout, clock: clock) }
  let(:clock) { Struct.new(:time).new(0) }
  let(:timeout) { 2 }

  context 'when created' do
    it 'has inner cancellations' do
      expect(either.left).to be_frozen.and eq(left)
      expect(either.right).to be_frozen.and eq(right)
    end
  end

  describe '#cancelled?' do
    it 'returns the current state of a cancellation', 'with the left branch' do
      expect { control.done }.to change(either, :cancelled?).from(false).to(true)
      expect(either.name).to eq('Left')
    end

    it 'returns the current state of a cancellation', 'with the right branch' do
      expect { clock.time = 3 }.to change(either, :cancelled?).from(false).to(true)
      expect(either.name).to eq('Right')
    end
  end

  describe '#check!' do
    let(:cancelled) { BM::Cancellation::ExecutionCancelled }
    let(:expired) { BM::Cancellation::DeadlineExpired }

    it 'raises when a cancellation cancelled', 'with the left branch' do
      expect(either.check!).to be_nil
      control.done
      expect { either.check! }.to raise_error(cancelled, 'Execution [Left] cancelled')
      expect(either.name).to eq('Left')
    end

    it 'raises when a cancellation cancelled', 'with the right branch' do
      expect(either.check!).to be_nil
      clock.time = timeout + 1
      expect { either.check! }.to raise_error(expired, 'Deadline [Right] expired after 2.0s')
      expect(either.name).to eq('Right')
    end
  end

  describe '#expires_after' do
    it 'returns a current timeout in seconds' do
      expect { clock.time = 1 }.to change(either, :expires_after).from(2).to(1)
    end
  end

  it_behaves_like 'when a cancellation has created by the factory', name: '(Left | Right)'
  it_behaves_like 'combines into an Either'
end

