class Csv::SplitAdjustedService < Csv::BaseService
  private

  def generate_csv
    CSV.generate do |csv|
      csv << headers.map(&:camelize)

      records.each do |record|
        csv << headers.map { |attr| record[attr.to_sym] }
      end
    end
  end

  def headers
    [
      'deal_id',
      'name',
      'advertiser',
      'agency',
      'team_member',
      'split',
      'budget',
      'stage',
      'probability',
      'type',
      'source',
      'next_steps',
      'start_date',
      'end_date',
      'created_date',
      'closed_date'
    ]
  end
end
