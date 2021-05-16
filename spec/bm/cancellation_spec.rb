# frozen_string_literal: true

RSpec.describe BM::Cancellation do
  it 'has a version number' do
    digit = '\d+'
    expect(BM::Cancellation::VERSION).to match(/\A#{digit}\.#{digit}\.#{digit}\z/)
  end
end
