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
    rules = create_rule_chain

    rules.each do |rule|
      invoice = rule.apply(invoice)
    end

    invoice.total
  end

  private

  attr_reader :basket

  def create_invoice_for(basket)
    Invoice.new(basket)
  end

  def create_rule_chain
    rules = [DefaultRule.new]

    if @pricing_rules.include?('buy-one-get-one-free')
      rules << BuyOneGetOneFreeRule.new
    end

    if @pricing_rules.include?('bulk-discount')
      rules << BulkDiscountRule.new
    end
    rules
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
  # TODO: these can be configured from yaml file
  BULK_DISCOUNT_CODES = ['AP1'].freeze
  DISCOUNT_PERCENTAGE = 0.10.freeze
  MINIMUM_BULK_COUNT = 3.freeze

  # Reduces the charged price by 10% when a product has more than 3 units
  def apply(invoice)
    invoice.invoice_items.each do |invoice_item|
      if BULK_DISCOUNT_CODES.include?(invoice_item.product_code) && invoice_item.count >= MINIMUM_BULK_COUNT
        invoice_item.charged_unit_price =
          invoice_item.price_per_unit - (invoice_item.price_per_unit * DISCOUNT_PERCENTAGE)
      end
    end

    invoice
  end
end

class BuyOneGetOneFreeRule < Rule
  # TODO: this can be configured from yaml file
  BUY_ONE_GET_ONE_FREE_CODES = ['FR1'].freeze

  # Charges only half of the FR1 items
  def apply(invoice)
    invoice.invoice_items.each do |invoice_item|
      if BUY_ONE_GET_ONE_FREE_CODES.include?(invoice_item.product_code)
        invoice_item.charged_count = (invoice_item.count.to_f / 2).ceil
      end
    end

    invoice
  end
end
