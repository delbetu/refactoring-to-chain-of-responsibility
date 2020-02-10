class Rule
  attr_accessor :next_rule

  def apply(invoice)
    next_rule.apply(invoice)
  end
end

class LastRule < Rule
  def apply(package) # Do not continue the chain
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

    next_rule.apply(invoice)
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

    next_rule.apply(invoice)
  end
end
