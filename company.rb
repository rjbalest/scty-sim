
# TODO: account for depreciation of assets
# TODO: account for corporate taxes

class Company

      # Think of capcity of 1 = 1 Gw
      # Think of the time step as 1 year
      # 

      InstalledCostPerWatt = 2.74  # actual number reported for Q4 2015
      CostPerWattDrop = 0.05       # 5% reduction each year 

      FederalRebate = 0.0         # 30% federal rebate
      CorporateTaxRate = 0.30      # Not accounting for this

      # Not currently accounting for this
      DepreciationRate = 0.05
      
      FinancingRate = 0.06         # rate at which money can be raised via loan or collateralized debt
      SolarHoursPerYear = 1500.0   # national average of 4 hours per day of full sunlight
      UtilityRate = 0.15           # 15 cents per Kw-Hr
      UtilityRateIncrease = 0.02   # 2% increase per year
      
      StepsPerYear = 4             # step by quarters
      CapacityGrowthRate = 1.0     # modifier to growth rate

      # Expressed as a fraction of the capacity
      # So, 2 Billion in added capacity would mean
      # an overhead cost of 600 Million at 0.3 overhead rate
      OverheadRate = 0.0          # Assuming these General and Admin costs not included in cost of installation

      attr_reader :name
      attr_reader :ticker

      attr_accessor :cash
      attr_reader :debt
      attr_accessor :shares
      attr_accessor :capacity

      attr_reader :self_funding
      attr_reader :debt_free
      attr_reader :cash_positive
      attr_reader :market_cap_at_debt_free

      attr_accessor :financing_rate
      attr_accessor :capacity_growth_rate
      attr_accessor :utility_rate
      attr_accessor :overhead_rate
      attr_accessor :cost_per_watt
      attr_accessor :solar_hours_per_year

      attr_accessor :steps_per_year

      def initialize(ticker, name)
      	  @ticker = ticker
          @name = name

	  @time = 0
	  @steps_per_year = StepsPerYear
	  @capacity = 2.0

	  @cash = -6.0
	  @earnings = 0
	  @cost_per_watt = InstalledCostPerWatt
	  @cost_per_watt_t0 = nil
	  @capacity_growth_rate = CapacityGrowthRate

          @utility_rate = UtilityRate
          @overhead_rate = OverheadRate
	  @solar_hours_per_year = SolarHoursPerYear

	  @debt_max=0
	  @debt_free = nil
	  @self_funding = nil
	  @cash_positive = nil
          @market_cap_at_debt_free = 0
	  @pe=nil

	  @capacity_t = [[2.0,alpha]]
	  @capacity_d = [[6.0,alpha]]
      end
      

      # Growth in capacity during a step
      def capacity_growth
          # Assume we will grow indefinitely
      	  if @time > 120000
	    0.0
	  else
	    capacity_growth_rate / steps_per_year.to_f
 	  end
      end

      # I normalized solar units to mean 1000 hours = 1 S.U.
      def solar_units_per_step
      	  (solar_hours_per_year/1000.0)/steps_per_year.to_f
      end

      def cost_per_watt
          @cost_per_watt
      end

      # Profitability boils down to this.  And the finance rate.
      # The dimensions of alpha are 1/Time
      def alpha
      	   (solar_hours_per_year/1000.0) * utility_rate / cost_per_watt
      end	  

      def alpha_step
      	  alpha/steps_per_year.to_f
      end

      # Here we assume that the federal rebate will
      # end at some point in the future.
      def federal_rebate
          cutoff = 5.0 * steps_per_year.to_f
      	  if @time > cutoff
	     0.0
	  else
	     FederalRebate
	  end
      end

      # Revenue generated during one step.
      # This has to be a summation over (capacity_t, alpha_t)
      def revenue
      	  # capacity * alpha_step
	  sum = 0.0
	  # @capacity_t.each do |tup|
	  @capacity_d.each do |tup|
	    alpha_s = tup[1] / steps_per_year.to_f
	    sum += ( tup[0] * alpha_s )
	  end
	  sum
      end	 

      def earnings
          #print "  >>> %.3f   %.3f   %.3f  %.3f\n" % [ revenue, overhead_expense, interest_expense, capital_expense ]
      	  current = revenue
	  current -= overhead_expense
	  current -= interest_expense
	  if current > 0 and cash_positive.nil?
	     @cash_positive = @time
	  end
	  # Move capex out of earnings
	  #current -= capital_expense
	  current
      end

      def earnings_after_tax
      	  earnings * ( 1.0 - CorporateTaxRate )
      end

      def market_cap
      	  multiple = 12.0
      	  multiple * steps_per_year.to_f * (earnings_after_tax)
      end

      def debt_max
      	  @debt_max.abs
      end

      def debt
      	  @cash < 0 ? @cash.abs : 0.0
      end

      # The assumption here is that overhead is dominated by capacity growth
      # and not maintenance of existing capacity.  Currently we are guessing
      # that it is some fraction.  For example if capacity growth equates to
      # 2 billion dollars and overhead is 30%, that is 600 million overhead.
      def overhead_expense
      	  capacity_growth * overhead_rate
      end

      # Factor needed to calculate future capex
      # when ppw is time dependent
      def capex_multiplier
      	  mult = @cost_per_watt.to_f / @cost_per_watt_t0.to_f
	  mult 
      end
	  
      # I later realized that if ppw if time dependent then capital expense
      # should decrease over time for a fixed capacity growth. Oops
      def capital_expense
      	  capex = capacity_growth * @cost_per_watt * ( 1.0 - federal_rebate )
	  capex
      end

      def interest_expense
      	  if @cash < 0.0
	     @cash.abs * financing_rate / steps_per_year.to_f
	  else
	     0.0
	  end      	  
      end

      def financing_rate
      	  if @financing_rate.nil?
	     FinancingRate
	  else
	     @financing_rate
	  end
      end

      def step

	  # Note some starting values
      	  if @time == 0
	     @cost_per_watt_t0 = cost_per_watt
	     @capacity_t = [[capacity,alpha]]
	     @capacity_d = [[debt,alpha]]
	  end

      	  @time += 1
	  
	  @cash += earnings
	  @cash -= capital_expense
	  @capacity += capacity_growth

	  # Time dependent (capacity,alpha)
	  # Possibly this could be done the same by scaling capacity by alpha ratio to effective capacity
	  @capacity_t << [capacity_growth, alpha]
	  @capacity_d << [capacity_growth*@cost_per_watt, alpha]

	  # Reduce the cost per watt over time indefinitely
          # Should study capping this at some cutoff
      	  drop = (CostPerWattDrop.to_f / steps_per_year.to_f) * @cost_per_watt
	  if @cost_per_watt > 1.50
      	    @cost_per_watt -= drop
          end

          # Increase the utility rate over time
          hike = (UtilityRateIncrease.to_f / steps_per_year.to_f) * @utility_rate
          @utility_rate += hike unless @utility_rate.nil?

          # Increase the capacity growth
          cap_growth = { 1 => 0.5, 3 => 1.5, 4 => 1.75, 5 => 2.0, 6 => 2.50, 7 => 3.0 }
          if @time % steps_per_year == 0
            year = @time / steps_per_year
            if cap_growth.has_key? year
              #capacity_growth_rate = cap_growth[year]
              #print ">>>> Capcity set to %f\n" % capacity_growth_rate
            end
          end
          
	  # Note when self funded growth happens
	  if earnings > capital_expense and self_funding.nil?
	     @self_funding = @time
	  end

	  # Note when debt free
	  if @cash > 0 and debt_free.nil?
	     @debt_free = @time
	     @market_cap_at_debt_free = market_cap
	  end
	     
          # Note the max debt
	  if @cash < @debt_max
	     @debt_max = @cash
          end

      end	  
      
      
end
