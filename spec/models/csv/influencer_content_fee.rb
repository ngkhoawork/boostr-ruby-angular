require 'rails_helper'

RSpec.describe Csv::InfluencerContentFee, type: :model do
  context 'import' do
  	before do 
  		content_fee
  	end

    it 'create new influencer content fee' do
      expect {
        Csv::InfluencerContentFee.import(file, user.id, 'influencer_content_fee.csv')
      }.to change(InfluencerContentFee, :count).by(1)

      influencer_content_fee = company.influencer_content_fees.last

      expect(influencer_content_fee.fee_type).to eq('percentage')
      expect(influencer_content_fee.fee_amount).to eq(50)
			expect(influencer_content_fee.gross_amount_loc).to eq(10000)
      expect(influencer_content_fee.asset).to eq('www.google.com')
      expect(influencer_content_fee.effect_date.year).to eq(2016)
      expect(influencer_content_fee.effect_date.month).to eq(9)
      expect(influencer_content_fee.effect_date.day).to eq(28)
    end
  end

  private

  def company
    @_company ||= create :company
  end

  def user
    @_user ||= create :user, company: company, email: 'test@user.com'
  end

  def io
  	@_io ||= create :io, company: company
  end

  def influencer
  	@_influencer ||= create :influencer, company: company
  end

  def product
    @_product ||= create :product, company: company
  end

  def content_fee
    @_content_fee = create :content_fee, io: io, product: product
  end

  def file
    @_file = CSV.generate do |csv|
      csv << ['IO Num', 'Influencer ID', 'Product', 'Product Level1', 'Product Level2', 'Date', 'Fee Type', 'Fee Amt', 'Gross', 'Asset']
      csv << [io.io_number, influencer.id, product.name, nil, nil, '9/28/2016', 'percentage', 50, 10000, 'www.google.com']
      csv << [io.io_number, influencer.id, 'fake', nil, nil, '1/8/2017', 'percentage', 50, 10000, 'www.google.com']
    end
  end	
end