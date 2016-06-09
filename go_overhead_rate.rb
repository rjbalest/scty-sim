#!/usr/bin/ruby

require './company.rb'

# Study what happens when you vary the capacity growth rate
rates = [0.1,0.15,0.2,0.25,0.3]
cash_positive = {}
debt_max = {}
self_funding = {}
debt_free = {}
market_cap = {}
revenue = {}

rates.each do |rate|

SCTY = Company.new("SCTY", "Solar City")
SCTY.overhead_rate = rate

print "%s (%s)\n" % [SCTY.name,SCTY.ticker]

print "Time    Capacity    Cash    CostPerWatt  [ alpha = %f ]\n" % [SCTY.alpha]
240.times do |s|
	 #print "%d:     %f   %f   %f\n" % [ s, SCTY.capacity, SCTY.cash, SCTY.cost_per_watt ]
	 SCTY.step
end

if SCTY.cash_positive
   print "Cash flow postive at step %d\n" % SCTY.cash_positive
   cash_positive[rate] = SCTY.cash_positive
end
if SCTY.self_funding
   print "Self funded growth at step %d\n" % SCTY.self_funding
   self_funding[rate] = SCTY.self_funding
end
if SCTY.debt_free
   print "Debt free at step %d\n" % SCTY.debt_free
   debt_free[rate] = SCTY.debt_free
end
print "Maximum debt: %.2f\n" % SCTY.debt_max
debt_max[rate] = SCTY.debt_max

print "Market Capitalization: %.2f\n" % SCTY.market_cap
market_cap[rate] = SCTY.market_cap

end

print "Rate   Positive   MaxDebt   SelfFunding   DebtFree   MarketCap\n"
rates.each do |rate|
print "%.2f   %d         %.2f      %d            %d         %f\n" % [ rate, cash_positive[rate], debt_max[rate], self_funding[rate], debt_free[rate], market_cap[rate] ]
end
