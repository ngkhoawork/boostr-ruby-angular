class Csv::ProductMonthlySummaryService < Csv::BaseService
  def initialize(company, data)
    @company = company
    @data = data['data']
    @custom_field_names = data['deal_product_cf_names']
  end

  private

  attr_reader :company

  def generate_csv
    CSV.generate do |csv|
      csv << headers
      @data.each do |row|
        record = []
        record << row['product']
        @custom_field_names.each do |cf|
          record << row['custom_fields'][cf['field_type'].to_s + cf['field_index'].to_s]
        end
        record << row['record_type']
        record << row['record_id']
        members = ''
        row['members'].each do |member|
          members << "#{member['name']} #{member['share'] || 0}% "
        end
        record << members
        record << row['name']
        record << (row['advertiser']['name'] rescue '')
        record << (row['agency']['name'] rescue '')
        record << row['holding_company']
        record << (row['stage']['name'] rescue '')
        record << (row['stage']['probability'] rescue '')
        record << ActiveSupport::NumberHelper.number_to_currency(row['budget_loc'], precision: 0, unit: row['currency'] || '$')
        record << ActiveSupport::NumberHelper.number_to_currency(row['budget'], precision: 0)
        record << ActiveSupport::NumberHelper.number_to_currency(row['weighted_budget'], precision: 0)
        record << (row['start_date'] ? Time.parse(row['start_date']).strftime('%m/%d/%Y') : '')
        record << (row['end_date'] ? Time.parse(row['end_date']).strftime('%m/%d/%Y') : '')
        record << (row['created_at'] ? Time.parse(row['created_at']).strftime('%m/%d/%Y') : '')
        record << (row['closed_at'] ? Time.parse(row['closed_at']).strftime('%m/%d/%Y') : '')
        record << row['type']
        record << row['source']

        csv << record
      end
    end
  end

  def headers
    headers = ['Product']
    headers += @custom_field_names.map {|cf| cf['field_label']}
    headers.concat ['Record Type', 'Record ID', 'Team Member', 'Name', 'Advertiser', 'Agency', 'Holding CO', 'Stage', '%', 'Budget', 'Budget USD', 'Weighted Amt', 'Start Date', 'End Date', 'Created Date', 'Closed Date', 'Deal Type', 'Deal Source']
  end
end
