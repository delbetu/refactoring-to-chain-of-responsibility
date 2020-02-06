require 'checkout'

describe Checkout do
  it 'accumulates items and returns the total' do
    item = Item.new('FR1', 'product1', 25.5)
    subject = Checkout.new
    subject.scan(item)
    expect(subject.total).to eq 25.5
  end
end
