class RuleChain
  def initialize(initial_rule)
    @initial_rule = @last_rule = initial_rule
  end

  def start(package)
    use(LastRule.new) # Ensure last item will finish the chaining calls
    @initial_rule.apply(package)
  end

  def use(rule)
    @last_rule.next_rule = rule
    @last_rule = @last_rule.next_rule
  end
end
