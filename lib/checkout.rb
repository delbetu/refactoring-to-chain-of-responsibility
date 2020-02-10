require 'rule_chain'
require 'invoice'
require 'rules'

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
    checkout_process = create_rules_chain(@pricing_rules)
    checkout_process.start(invoice)

    invoice.total
  end

  private

  attr_reader :basket

  def create_invoice_for(basket)
    Invoice.new(basket)
  end

  def create_rules_chain(pricing_rules)
    chain = RuleChain.new(DefaultRule.new)

    if pricing_rules.include?('buy-one-get-one-free')
      chain.use(BuyOneGetOneFreeRule.new)
    end

    if pricing_rules.include?('bulk-discount')
      chain.use(BulkDiscountRule.new)
    end

    chain
  end
end
