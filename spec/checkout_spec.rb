require 'checkout'

describe Checkout do
  it 'accumulates items and returns the total' do
    item = double
    subject = Checkout.new
    subject.scan(item)
    expect(subject.total).to eq 50
  end
end
