## The problem

Given a supermarket which sell only three products:

```
+--------------|--------------|---------+
| Product Code |     Name     |  Price  |
+--------------|--------------|---------+
|     FR1      |   Fruit tea  |  $3.11  |
|     AP1      |   Apple      |  $5.00  |
|     CF1      |   Coffee     | $11.23  |
+--------------|--------------|---------+
```

The owner is a big fan of buy-one-get-one-free offers and of fruit tea. He wants us to add a rule to do this.

Also he likes low prices and wants people buying apple to get a price 
discount for bulk purchases. If you buy 3 or more apples, the price should drop to $4.50.
Our check-out can scan items in any order, and it needs to be flexible regarding our pricing rules.

The interface to our checkout looks like this:

```ruby
co = Checkout.new(pricing_rules)
co.scan(item)
co.scan(item)
price = co.total
```

Implement a checkout system that fulfils these requirements in Ruby.

Here are some test data:

Basket: FR1, AP1, FR1, CF1
Total price expected: $22.25
Basket: FR1, FR1
Total price expected: $3.11
Basket: AP1, AP1, FR1, AP1
Total price expected: $16.61

## The solution

This repository implements a solution to the previous problem.  
If you follow the commits you can see how it was building.  
In particular you can see the usage of `TDD`, `Refactoring` and `Design-Patterns` applied.

