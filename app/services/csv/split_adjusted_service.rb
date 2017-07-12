class Csv::SplitAdjustedService < Csv::BaseService
  private
  #TODO tests. Possible refactoring

  def generate_csv
    CSV.generate do |csv|
      csv << headers

      records.each do |record|
        line = []
        line << record[:deal_id]
        line << record[:deal_name]
        line << record[:advertiser]['name']
        line << (record[:agency].present? ? record[:agency]['name'] : nil)
        line << record[:name]
        line << record[:share]
        line << record[:stage]['name']
        line << record[:stage]['probability']
        line << record[:budget]
        line << record[:curr_cd]
        line << record[:budget_loc]
        line << record[:split_budget]
        line << record[:type]
        line << record[:source]
        line << record[:next_steps]
        line << record[:start_date]
        line << record[:end_date]
        line << record[:created_date]
        line << record[:closed_date]

        csv << line
      end
    end
  end

  def headers
    [
      'Deal Id',
      'Name',
      'Advertiser',
      'Agency',
      'Team Member',
      'Split',
      'Stage',
      '%',
      'Budget',
      'Currency',
      'Budget USD',
      'Split Budget USD',
      'Type',
      'Source',
      'Next steps',
      'Start date',
      'End date',
      'Created Date',
      'Closed Date'
    ]
  end
end
