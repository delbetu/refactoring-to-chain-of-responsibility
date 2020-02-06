Item = Struct.new(:code, :name, :price)

class Checkout
  def initialize
    @total_price = 0
  end

  def scan(item)
    @total_price += item.price
  end

  def total
    @total_price
  end
end
