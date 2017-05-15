namespace :time_periods do
  desc 'Add weeks for time periods'
  task add_weeks: :environment do
    file = File.open("#{Rails.root}/lib/files/pacing_dash.csv", 'r:ISO-8859-1')

    CSV.parse(file, { headers: true, header_converters: :symbol }) do |row|
      TimePeriodWeek.create(
        week: row[:week],
        start_date: Date.strptime(row[:start], '%m/%d/%Y'),
        end_date: Date.strptime(row[:end], '%m/%d/%Y'),
        period_name: row[:time_period],
        period_start: Date.strptime(row[:time_period_start], '%m/%d/%Y'),
        period_end: Date.strptime(row[:time_period_end], '%m/%d/%Y')
      )
    end
  end
end
