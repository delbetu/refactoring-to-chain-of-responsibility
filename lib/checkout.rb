Item = Struct.new(:code, :name, :price)

class Checkout
  def initialize(pricing_rules=[])
    @pricing_rules = pricing_rules
    @basket = []
    @total_price = 0
  end

  def scan(item)
    @basket << item
  end

  def total
    if @pricing_rules.include?('buy-one-get-one-free')
      fruit_tea_items = @basket.find_all {|purchased_product| purchased_product.code == 'FR1'}
      non_fruit_tea_items = @basket.find_all {|purchased_product| purchased_product.code != 'FR1'}

      if fruit_tea_items.length.even?
        # charge only half of the items
        fruit_tea_items_total = fruit_tea_items.inject(0) { |total, purchased_product| total + purchased_product.price } / 2
      else
        # charge first and half of the rest
        first_fruit_item = fruit_tea_items.pop
        fruit_tea_items_total = first_fruit_item + fruit_tea_items.inject(0) { |total, purchased_product| total + purchased_product.price } / 2
      end

      non_fruit_tea_items_total = non_fruit_tea_items.inject(0) { |total, purchased_product| total + purchased_product.price }

      non_fruit_tea_items_total + fruit_tea_items_total
    else
      @basket.inject(0) { |total, purchased_product| total + purchased_product.price }
    end
  end

  private

  attr_reader :basket

  def fruit_tea_already_added(item)
    basket.find { |product| product.code = item.code }
  end
end
