Item = Struct.new(:code, :name, :price)

InvoiceItem = Struct.new(:product_code, :count, :price_per_unit, :charged_unit_price, :charged_amount)

class Invoice
  def initialize(basket)
    # [ ('FR1', 55 items, 20 $ each) ]
    @invoice_items = basket.group_by { |item| item.code }
      .map { |code, items| InvoiceItem.new(code, items.length, items.first.price) }
  end

  def total
    @invoice_items.inject(0) do |total, invoice_item|
      total + ( invoice_item.charged_unit_price * invoice_item.charged_amount )
    end
  end
end

class Checkout
  def initialize(pricing_rules=[])
    @pricing_rules = pricing_rules
    @basket = []
  end

  def scan(item)
    @basket << item
  end

  def total
    if @pricing_rules.include?('buy-one-get-one-free')
      BuyOneGetOneRule.new(@basket).total
    else
      DefaultRule.new(@basket).total
    end
  end

  private

  attr_reader :basket

  def fruit_tea_already_added(item)
    basket.find { |product| product.code = item.code }
  end
end

class DefaultRule
  def initialize(basket)
    @basket = basket
    @invoice = Invoice.new(basket)
  end

  def total
    @basket.inject(0) { |total, purchased_product| total + purchased_product.price }
  end
end

class BuyOneGetOneRule
  def initialize(basket)
    @basket = basket
    @invoice = Invoice.new(basket)
  end

  def total
    fruit_tea_items = @basket.find_all {|purchased_product| purchased_product.code == 'FR1'}
    non_fruit_tea_items = @basket.find_all {|purchased_product| purchased_product.code != 'FR1'}

    if fruit_tea_items.length.even?
      # charge only half of the items
      fruit_tea_items_total = fruit_tea_items.inject(0) { |total, purchased_product| total + purchased_product.price } / 2
    else
      # charge first and half of the rest
      first_fruit_item = fruit_tea_items.pop
      fruit_tea_items_total = first_fruit_item.price + fruit_tea_items.inject(0) { |total, purchased_product| total + purchased_product.price } / 2
    end

    non_fruit_tea_items_total = non_fruit_tea_items.inject(0) { |total, purchased_product| total + purchased_product.price }

    non_fruit_tea_items_total + fruit_tea_items_total
  end
end
