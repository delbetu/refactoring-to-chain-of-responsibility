require 'checkout'

describe Checkout do
  describe 'accumulating item prices' do
    it 'returns the only item price added to the basket' do
      item = Item.new('FR1', 'product1', 25.5)
      subject = Checkout.new
      subject.scan(item)
      expect(subject.total).to eq 25.5
    end

    it 'returns 2 times the total of the item when adding same item twice' do
      item = Item.new('FR1', 'product1', 25.5)
      subject = Checkout.new
      subject.scan(item)
      subject.scan(item)
      expect(subject.total).to eq 51.0
    end
  end
end
