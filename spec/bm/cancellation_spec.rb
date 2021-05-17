# frozen_string_literal: true

require 'bm/cancellation'

RSpec.describe BM::Cancellation do
  it 'has a version number' do
    digit = '\d+'
    expect(BM::Cancellation::VERSION).to match(/\A#{digit}\.#{digit}\.#{digit}\z/)
  end

  describe '.new' do
    it 'returns a cancellation control' do
      control = described_class.new
      expect(control).to be_kind_of(described_class::Control).and be_frozen
    end

    it 'destructs into array' do
      cancellation, control = described_class.new
      expect(control).to be_kind_of(described_class::Control).and be_frozen
      expect(cancellation).to be_kind_of(described_class).and be_frozen
    end
  end

  describe '.timeout' do
    it 'returns a deadline' do
      deadline = described_class.timeout(seconds: 5)
      expect(deadline).to be_kind_of(described_class::Deadline)
    end
  end

  describe '.current' do
    subject(:cancellation) { described_class.new.cancellation }

    it 'returns a cancellation from TLS' do
      cancellation.using do
        expect(described_class.current).to eq(cancellation)
      end
    end

    it 'returns a cancellation from TLS', 'and restores a previous cancellation' do
      previous = described_class.new.cancellation

      previous.using do
        cancellation.using do
          expect(described_class.current).to eq(cancellation)
        end
        expect(described_class.current).to eq(previous)
      end
    end

    it 'raises an ArgumentError when no cancellation in the current thread' do
      msg = 'No cancellation found in the current thread'
      expect { described_class.current }.to raise_error(ArgumentError, msg)
    end
  end

  describe '.current?' do
    it 'checks that a cancellation is exists' do
      expect(described_class).not_to be_current
      described_class.new.cancellation.using do
        expect(described_class).to be_current
      end
      expect(described_class).not_to be_current
    end
  end
end
