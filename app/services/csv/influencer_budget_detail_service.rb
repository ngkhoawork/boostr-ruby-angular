class Csv::InfluencerBudgetDetailService < Csv::BaseService
  private

  def decorated_records
    records.map { |record| Csv::InfluencerBudgetDetailDecorator.new(record) }
  end

  def headers
    [
    	'Team',
    	'IO Number',
    	'Advertiser',
    	'Agency',
    	'Seller',
    	'Account Manager',
    	'Product',
    	'Total Budget',
    	'IO Start Date',
    	'Asset Date',
    	'Influencer',
    	'Network',
    	'Fee Type',
    	'Fee',
    	'Gross Amount',
    	'Net Amount',
    	'Asset Link'
    ]
  end
end
