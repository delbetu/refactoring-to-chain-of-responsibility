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

    invoice = DefaultRule.new(invoice).apply

    if @pricing_rules.include?('buy-one-get-one-free')
      invoice = BuyOneGetOneFree.new(invoice).apply
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
  def initialize(invoice)
    @invoice = invoice
  end

  def apply
    @invoice
  end
end

class DefaultRule < Rule
end

class BuyOneGetOneFree < Rule
  # Charges only half of the FR1 items
  def apply
    @invoice.invoice_items.each do |invoice_item|
      if invoice_item.product_code == 'FR1'
        invoice_item.charged_count = (invoice_item.count.to_f / 2).ceil
      end
    end

    @invoice
  end
end
