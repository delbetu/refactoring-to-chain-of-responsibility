require 'checkout'

describe Checkout do
  let(:coffee) { Item.new('CF1', 'Coffee', 11.23) }
  let(:apple) { Item.new('AP1', 'Apple', 5.00) }
  let(:fruit_tea) { Item.new('FR1', 'Fruit tea', 3.11) }
  subject { Checkout.new(['buy-one-get-one-free', 'bulk-discount']) }

  it 'Basket: FR1, AP1, FR1, CF1 Total price expected: $22.25' do
    subject.scan(fruit_tea)
    subject.scan(apple)
    subject.scan(fruit_tea)
    subject.scan(coffee)

    expect(subject.total).to eq 19.34
  end

  it 'Basket: FR1, FR1 Total price expected: $3.11' do
    subject.scan(fruit_tea)
    subject.scan(fruit_tea)

    expect(subject.total).to eq 3.11
  end

  it 'Basket: AP1, AP1, FR1, AP1 Total price expected: $16.61' do
    subject.scan(apple)
    subject.scan(apple)
    subject.scan(fruit_tea)
    subject.scan(apple)

    expect(subject.total).to eq 16.61
  end
end
