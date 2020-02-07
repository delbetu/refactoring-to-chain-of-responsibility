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

  describe 'discount for bulk purchases' do
    # If you buy 3 or more apples, the price should drop to $4.50.
    it 'charges regular price when buying two apples' do
      apple = Item.new('AP1', 'apple', 5.0)
      subject = Checkout.new(['bulk-discount'])
      subject.scan(apple)
      subject.scan(apple)

      expect(subject.total).to eq(10.0)
    end

    it 'applies 10% discount when buying 3 apples' do
      apple = Item.new('AP1', 'apple', 5.0)
      subject = Checkout.new(['bulk-discount'])
      subject.scan(apple)
      subject.scan(apple)
      subject.scan(apple)

      expect(subject.total).to eq(4.5*3)
    end
  end

  describe 'mixing discount rules' do
    it 'applies bulk discount and buy-one-get-one-free rules' do
      apple = Item.new('AP1', 'apple', 5.0)
      fruit_tea = Item.new('FR1', 'product1', 10.0)

      subject = Checkout.new(['buy-one-get-one-free', 'bulk-discount'])

      5.times { subject.scan(fruit_tea) }

      5.times { subject.scan(apple) }

      expect(subject.total).to eq(4.5*5 + 10.0*3)
    end

    describe 'applying rules to multiple products' do
      it 'gives you one apple and a fruit-tea for free' do
        stub_const('BuyOneGetOneFreeRule::BUY_ONE_GET_ONE_FREE_CODES', ['AP1', 'FR1'])
        apple = Item.new('AP1', 'apple', 5.0)
        fruit_tea = Item.new('FR1', 'product1', 10.0)

        subject = Checkout.new(['buy-one-get-one-free'])

        subject.scan(fruit_tea)
        subject.scan(fruit_tea)
        subject.scan(apple)
        subject.scan(apple)

        expect(subject.total).to eq(5.0*1 + 10.0*1)
      end

      it 'gives you 10% discount on fruit-tea and apple' do
        stub_const('BulkDiscountRule::BULK_DISCOUNT_CODES', ['AP1', 'FR1'])

        apple = Item.new('AP1', 'apple', 5.0)
        fruit_tea = Item.new('FR1', 'product1', 10.0)

        subject = Checkout.new(['bulk-discount'])

        subject.scan(fruit_tea)
        subject.scan(fruit_tea)
        subject.scan(fruit_tea)
        subject.scan(apple)
        subject.scan(apple)
        subject.scan(apple)

        expect(subject.total).to eq(4.5*3 + 9.0*3)
      end

      it 'gives you 10% discount and buy-one-get-one free for fruit-tea and apple' do
        stub_const('BulkDiscountRule::BULK_DISCOUNT_CODES', ['AP1', 'FR1'])
        stub_const('BuyOneGetOneFreeRule::BUY_ONE_GET_ONE_FREE_CODES', ['AP1', 'FR1'])

        apple = Item.new('AP1', 'apple', 5.0)
        fruit_tea = Item.new('FR1', 'product1', 10.0)

        subject = Checkout.new(['bulk-discount', 'buy-one-get-one-free'])

        subject.scan(fruit_tea)
        subject.scan(fruit_tea)
        subject.scan(fruit_tea)
        subject.scan(apple)
        subject.scan(apple)
        subject.scan(apple)

        expect(subject.total).to eq(4.5*2 + 9.0*2)
      end
    end
  end
end
