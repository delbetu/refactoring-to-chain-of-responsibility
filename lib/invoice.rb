
Item = Struct.new(:code, :name, :price)

InvoiceItem = Struct.new(:product_code, :count, :price_per_unit, :charged_unit_price, :charged_count)

# Represents items grouped by their code
# Calculates total based on the final prices and items count of these groups
class Invoice
  attr_reader :invoice_items

  def initialize(basket)
    # [ ('FR1', 55 items, 20 $ each) ]
    @invoice_items = basket.group_by { |item| item.code }
      .map { |code, items| InvoiceItem.new(code, items.length, items.first.price, items.first.price, items.length) }
  end

  def total
    @invoice_items.inject(0) do |total, invoice_item|
      total + ( invoice_item.charged_unit_price * invoice_item.charged_count )
    end
  end
end

