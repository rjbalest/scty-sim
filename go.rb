#!/usr/bin/ruby

require './company.rb'

SCTY = Company.new("SCTY", "Solar City")

SCTY.cash = -6.0                  # starting with 6B debt
SCTY.capacity = 2.0               # starting with 2T capacity
SCTY.financing_rate = 0.06        # 6%
SCTY.utility_rate = 0.15          # 15 cents per Kw-Hr
SCTY.cost_per_watt = 2.75         # 2.75 per watt
SCTY.solar_hours_per_year = 1500  # 1500 mean hours in USA 
SCTY.capacity_growth_rate = 1.0   # 1GW per year

print "Year  Quarter  Capacity     Cash       Revenue      Market Cap\n"

# Simulate 20 years starting in Q1 2016
SCTY.steps_per_year = 4
steps = 20 * SCTY.steps_per_year
year = 2016
steps.times do |s|
	 quarter = (s % 4) + 1
	 print "%d   Q%d:      %.2f       %.2f        %.2f        %.2f\n" % [ year, quarter, SCTY.capacity, SCTY.cash, SCTY.revenue,SCTY.market_cap ]
	 SCTY.step
	 if quarter == 4
	    year = year + 1
         end
end

if SCTY.cash_positive
   print "Cash flow postive at step %d\n" % SCTY.cash_positive
end
if SCTY.self_funding
   print "Self funded growth at step %d\n" % SCTY.self_funding
end
if SCTY.debt_free
   print "Debt free at step %d\n" % SCTY.debt_free
end
print "Maximum debt: %.2f\n" % SCTY.debt_max
print "Market Capitalization: %.2f\n" % SCTY.market_cap
