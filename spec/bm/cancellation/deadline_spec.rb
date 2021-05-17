# frozen_string_literal: true

require 'bm/cancellation'

RSpec.describe BM::Cancellation::Deadline do
  subject(:deadline) { BM::Cancellation.timeout(seconds: timeout, clock: clock) }

  let(:timeout) { 2 }
  let(:clock) { Struct.new(:time).new(0) }

  context 'when created' do
    it 'does not to be expired' do
      expect(deadline).not_to be_expired
    end
  end

  describe '#cancelled?' do
    it 'returns the current state of a cancellation' do
      expect { clock.time = timeout + 1 }.to change(deadline, :cancelled?).from(false).to(true)
    end
  end

  describe '#check!' do
    let(:expired) { BM::Cancellation::DeadlineExpired }

    it 'raises when a cancellation cancelled' do
      expect(deadline.check!).to be_nil
      clock.time = timeout + 1
      expect { deadline.check! }.to raise_error(expired, 'Deadline expired after 2.0s')
    end
  end

  describe '#expires_after' do
    it 'returns a current timeout in seconds' do
      expect { clock.time = 1 }.to change(deadline, :expires_after).from(2).to(1)
    end
  end

  it_behaves_like 'when a cancellation has created by the factory'
  it_behaves_like 'combines into an Either'
  it_behaves_like 'combines with a timeout'
  it_behaves_like 'combines with a signal'
end
