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

    it 'sums both item prices when adding different items' do
      item = Item.new('FR1', 'product1', 25.5)
      item2 = Item.new('FR2', 'product2', 20)

      subject = Checkout.new
      subject.scan(item)
      subject.scan(item2)

      expect(subject.total).to eq 45.5
    end

    it 'returns 0 when no item was added' do
      subject = Checkout.new
      expect(subject.total).to eq 0.0
    end

    it 'can sum a lot of items' do
      100.times {|i| subject.scan(Item.new("FR#{i}", "product#{i}", 10.0*i))}
      expect(subject.total).to eq (100*(100-1)/2)*10
    end
  end

  describe 'buy-one-get-one-free offers' do
    it "doesn't charge the second fruit tea" do
      item = Item.new('FR1', 'product1', 25.5)
      subject = Checkout.new(['buy-one-get-one-free'])
      subject.scan(item)
      subject.scan(item)
      expect(subject.total).to eq 25.5
    end

    it 'charges 5 when adding 10 fruit tea' do
      item = Item.new('FR1', 'product1', 10.0)
      subject = Checkout.new(['buy-one-get-one-free'])
      subject.scan(item)
      subject.scan(item)
      subject.scan(item)
      subject.scan(item)
      subject.scan(item)
      subject.scan(item)
      subject.scan(item)
      subject.scan(item)
      subject.scan(item)
      subject.scan(item)
      expect(subject.total).to eq 50.0
    end

    it 'charges 3 when adding 5 fruit tea' do
      item = Item.new('FR1', 'product1', 10.0)
      subject = Checkout.new(['buy-one-get-one-free'])
      subject.scan(item)
      subject.scan(item)
      subject.scan(item)
      subject.scan(item)
      subject.scan(item)
      expect(subject.total).to eq 30.0
    end

    it 'charges the non fruit items whitout discount' do
      item = Item.new('FR1', 'product1', 10.0)
      item2 = Item.new('FR2', 'product2', 15.0)
      subject = Checkout.new(['buy-one-get-one-free'])
      subject.scan(item)
      subject.scan(item)
      subject.scan(item)
      subject.scan(item)
      subject.scan(item)
      subject.scan(item2)
      expect(subject.total).to eq 45.0
    end
  end

  describe 'discount for bulk purchases'
end
