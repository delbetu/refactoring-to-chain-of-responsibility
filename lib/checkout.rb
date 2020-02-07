Item = Struct.new(:code, :name, :price)

InvoiceItem = Struct.new(:product_code, :count, :price_per_unit, :charged_unit_price, :charged_count)

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

class Checkout
  def initialize(pricing_rules=[])
    @pricing_rules = pricing_rules
    @basket = []
  end

  def scan(item)
    @basket << item
  end

  def total
    invoice = create_invoice_for(@basket)

    invoice = DefaultRule.new.apply(invoice)

    if @pricing_rules.include?('buy-one-get-one-free')
      invoice = BuyOneGetOneFree.new.apply(invoice)
    end

    if @pricing_rules.include?('bulk-discount')
      invoice = BulkDiscountRule.new.apply(invoice)
    end

    invoice.total
  end

  private

  attr_reader :basket

  def fruit_tea_already_added(item)
    basket.find { |product| product.code = item.code }
  end

  def create_invoice_for(basket)
    Invoice.new(basket)
  end
end

class Rule
  def apply(invoice)
    invoice
  end
end

class DefaultRule < Rule
  # total is calculated as product_count * regular_price
  # In this case prouct_count is the same as charged_count for a product code,
  # and regular prices is equal to charged_price
end

class BulkDiscountRule < Rule
  # Reduces the charged price by 10% when a product has more than 3 units
  def apply(invoice)
    discount_percentage = 0.10
    minimum_bulk_count = 3
    invoice.invoice_items.each do |invoice_item|
      if invoice_item.product_code == 'AP1' && invoice_item.count >= minimum_bulk_count
        invoice_item.charged_unit_price =
          invoice_item.price_per_unit - (invoice_item.price_per_unit * discount_percentage)
      end
    end

    invoice
  end
end

class BuyOneGetOneFree < Rule
  # Charges only half of the FR1 items
  def apply(invoice)
    invoice.invoice_items.each do |invoice_item|
      if invoice_item.product_code == 'FR1'
        invoice_item.charged_count = (invoice_item.count.to_f / 2).ceil
      end
    end

    invoice
  end
end
