class GenerateForecastTimeDimensionData < ActiveRecord::Migration
  def change
  	period_types = ['year', 'quarter', 'month']
  	TimePeriod.all.each do |time_period|
  		if period_types.include?(time_period.period_type)
  			ForecastTimeDimension.create({
  				id: time_period.id,
  				name: time_period.name,
  				start_date: time_period.start_date,
  				end_date: time_period.end_date,
  				days_length: (time_period.end_date - time_period.start_date + 1).to_i
  			})
  		end
  	end
  end
end
