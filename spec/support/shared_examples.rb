# frozen_string_literal: true

RSpec.shared_examples 'combines into an Either' do
  let(:a_right) { BM::Cancellation.cancel('Right').first }
  let(:a_left) { subject }

  describe '#or_else' do
    let(:an_either) { a_left.or_else(a_right) }

    it 'combines with a second cancellation' do
      expect(an_either).to be_kind_of(BM::Cancellation).and have_attributes(left: a_left, right: a_right)
    end
  end

  describe '#|' do
    let(:an_either) { a_left | a_right }

    it 'combines with a second cancellation' do
      expect(an_either).to be_kind_of(BM::Cancellation).and have_attributes(left: a_left, right: a_right)
    end
  end
end

RSpec.shared_examples 'when a cancellation has created by the factory' do |name:|
  it 'be frozen' do
    expect(subject).to be_frozen
  end

  it 'inherits from base class' do
    expect(subject).to be_kind_of(BM::Cancellation)
  end

  it 'does not cancelled' do
    expect(subject).not_to be_cancelled
  end

  it 'has a name' do
    expect(subject.name).to eq(name)
  end
end