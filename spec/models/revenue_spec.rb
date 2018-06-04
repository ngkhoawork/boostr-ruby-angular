require 'rails_helper'

RSpec.describe Revenue, type: :model do
  let!(:company) { create :company }
  let(:user) { create :user }
  let(:client) { create :client }
  let(:product) { create :product }

  describe 'scopes' do
    context 'for_time_period' do
      let(:time_period) { create :time_period, start_date: '2015-01-01', end_date: '2015-12-31' }
      let!(:in_revenue) { create :revenue, start_date: '2015-02-01', end_date: '2015-2-28'  }
      let!(:out_revenue) { create :revenue, start_date: '2016-02-01', end_date: '2016-2-28'  }

      it 'should return revenues that are completely in the time period' do
        expect(Revenue.for_time_period(time_period.start_date, time_period.end_date).count).to eq(1)
        expect(Revenue.for_time_period(time_period.start_date, time_period.end_date)).to include(in_revenue)
      end

      it 'returns revenues that are partially in the time period' do
        create :revenue, start_date: '2015-02-01', end_date: '2016-2-28'
        create :revenue, start_date: '2014-12-01', end_date: '2015-2-28'

        expect(Revenue.for_time_period(time_period.start_date, time_period.end_date).count).to eq(3)
      end
    end
  end

  describe 'uploading a good csv' do
    it 'creates a new revenue object for each row' do
      expect do
        Revenue.import(good_csv_file(client, user, product), company.id)
        expect(Revenue.first.user_id).to equal(user.id)
        expect(Revenue.first.client_id).to equal(client.id)
        expect(Revenue.first.product_id).to equal(product.id)
        expect(Revenue.first.price).to equal(700)
      end.to change(Revenue, :count).by(1)
    end

    it 'does not create any new revenue objects when they have already been created' do
      Revenue.import(good_csv_file(client, user, product), company.id)

      expect do
        Revenue.import(good_csv_file(client, user, product), company.id)
      end.to_not change(Revenue, :count)
    end

    it "strips non numeric characters" do
      expect(Revenue.numeric("$15,000")).to eq("15000")
    end


    it 'returns no errors when the upload is successful' do
      expect(Revenue.import(good_csv_file(client, user, product), company.id)).to eq([])
    end
  end

  describe 'uploading a bad csv' do
    it 'returns errors when a row is missing required data' do
      expect do
        response = Revenue.import(missing_required_csv(client, user, product), company.id)
        expect(response[0][:row]).to eq(1)
        expect(response[0][:message].length).to eq(3)
        expect(response[0][:message]).to include("Order number can't be blank")
        expect(response[0][:message]).to include("Line number can't be blank")
        expect(response[0][:message]).to include("Ad server can't be blank")
      end.to_not change(Revenue, :count)
    end

    it 'returns an error when the user is not found in the system' do
      expect do
        response = Revenue.import(missing_user_csv(client, product), company.id)
        expect(response[0][:row]).to eq(1)
        expect(response[0][:message].length).to eq(1)
        expect(response[0][:message][0]).to include('Sales Rep could not be found')
      end.to_not change(Revenue, :count)
    end

    it 'returns an error when the user is not found in the system' do
      expect do
        response = Revenue.import(missing_client_csv(user, product), company.id)
        expect(response[0][:row]).to eq(1)
        expect(response[0][:message].length).to eq(1)
        expect(response[0][:message][0]).to include('Client could not be found')
      end.to_not change(Revenue, :count)
    end

    it 'returns an error when the product is not found in the system' do
      expect do
        response = Revenue.import(missing_product_csv(client, user), company.id)
        expect(response[0][:row]).to eq(1)
        expect(response[0][:message].length).to eq(1)
        expect(response[0][:message]).to include('Product could not be found')
      end.to_not change(Revenue, :count)
    end

    it 'returns an error when the start date is missing' do
      expect do
        response = Revenue.import(missing_date_csv(client, user, product), company.id)
        expect(response[0][:row]).to eq(1)
        expect(response[0][:message].length).to eq(1)
        expect(response[0][:message]).to include('Start date can\'t be blank')
      end.to_not change(Revenue, :count)
    end

  end

  describe '#daily_budget' do
    let(:revenue) { create :revenue }

    it 'returns the daily budget amount based on budget and start and end dates' do
      expect(revenue.daily_budget).to eq(1000)
    end

    it 'returns the daily budget across months' do
      revenue.update_attributes(end_date: "2015-12-31", budget: 365_000)
      expect(revenue.daily_budget).to eq(1000)
    end

    it 'returns the daily budget without rounding' do
      revenue.update_attributes(end_date: "2015-2-14")
      expect(revenue.daily_budget).to eq(666.66)
    end
  end
end
