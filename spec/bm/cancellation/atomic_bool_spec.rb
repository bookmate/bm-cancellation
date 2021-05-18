# frozen_string_literal: true

require 'bm/cancellation'

RSpec.describe BM::Cancellation::AtomicBool do
  let(:bool) { described_class.new(false) }
  let(:argument_error) { [TypeError, 'wrong argument type boolean expected'] }

  describe '#new' do
    it 'raises an ArgumentError for non boolean value' do
      expect { described_class.new(0) }.to raise_error(*argument_error)
    end
  end

  describe '#swap' do
    it 'raises an ArgumentError for non boolean values' do
      expect { bool.swap(0, true) }.to raise_error(*argument_error)
      expect { bool.swap(true, 0) }.to raise_error(*argument_error)
    end

    it 'compares and swap' do
      expect(bool.fetch).to be_falsey
      expect(bool.swap(false, true)).to be_truthy
      expect(bool.value).to be_truthy
    end

    it 'compares an not swap when expected is not matched' do
      expect(bool.fetch).to be_falsey
      expect(bool.swap(true, false)).to be_falsey
      expect(bool.value).to be_falsey
    end
  end

  describe '#to_s' do
    it 'returns an atomic name' do
      expect(bool.to_s).to eq('BM::Cancellation::AtomicBool(false)')
    end
  end
end
