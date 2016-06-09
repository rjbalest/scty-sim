#!/usr/bin/ruby

require './company.rb'

rates = [0.0, 0.02, 0.04, 0.06, 0.08, 0.10]
cash_positive = {}
debt_max = {}
self_funding = {}
debt_free = {}
market_cap = {}
market_cap_df = {}
revenue = {}

rates.each do |rate|

SCTY = Company.new("SCTY", "Solar City")
SCTY.financing_rate = rate

print "%s (%s)\n" % [SCTY.name,SCTY.ticker]

print "Time    Capacity    Cash    CostPerWatt  [ alpha = %f ]\n" % [SCTY.alpha]
360.times do |s|
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

print "Market Capitalization @debt free: %.2f\n" % SCTY.market_cap_at_debt_free
market_cap_df[rate] = SCTY.market_cap_at_debt_free

print "Market Capitalization: %.2f\n" % SCTY.market_cap
market_cap[rate] = SCTY.market_cap

end

print "Rate   Positive   MaxDebt   SelfFunding   DebtFree   MarketCap ( @debt free )     MarketCap ( @30 years)\n"
rates.each do |rate|
print "%.2f   %d         %.2f      %d            %d         %f                       %f\n" % [ rate, cash_positive[rate], debt_max[rate], self_funding[rate], debt_free[rate], market_cap_df[rate], market_cap[rate] ]
end
