require 'rails_helper'

RSpec.describe Api::PublisherDetailsController, type: :controller do
  let!(:publisher) do
    create(
      :publisher,
      name: 'Amazon',
      company: company,
      client: client,
      publisher_stage: publisher_stage,
      type: publisher_type_option
    )
  end

  before { sign_in user }

  describe '#activities' do
    let!(:activity) { Activity.create!(company: company, user: user) }

    subject { get :activities, id: publisher.id }

    before { publisher.activities << activity }

    it 'returns publisher\'s activities' do
      subject
      expect(response).to have_http_status(200)
      expect(response_body).to be_a_kind_of Array
      expect(first_item[:id]).to eq activity.id
    end
  end

  describe '#associations' do
    let!(:member) { create(:publisher_member, publisher: publisher, user: user) }
    let!(:contact) { create(:contact, publisher: publisher, client: client, company: company) }

    subject { get :associations, id: publisher.id }

    it 'returns publisher\'s associations' do
      subject
      expect(response).to have_http_status(200)
      expect(response_body).to have_key :members
      expect(response_body).to have_key :contacts
      expect(response_body_member_ids).to include member.id
      expect(response_body_contact_ids).to include contact.id
    end
  end

  describe '#fill_rate_by_month_graph' do
    let!(:daily_actual_1) { create(:publisher_daily_actual, publisher: publisher, currency: currency) }
    let!(:daily_actual_2) { create(:publisher_daily_actual, publisher: publisher, currency: currency) }

    subject { get :fill_rate_by_month_graph, id: publisher.id }

    xit 'returns expressions info by months' do
      subject
      expect(response).to have_http_status(200)
      expect(response_body).to be_a_kind_of Array
      expect(first_item[:year_month]).to eq daily_actual_1.date.strftime('%Y-%m')
      expect(first_item[:curr_symbol]).to eq currency.curr_symbol
      expect(
        first_item[:month_available_impressions]
      ).to eq daily_actual_1.available_impressions + daily_actual_2.available_impressions
      expect(
        first_item[:month_filled_impressions]
      ).to eq daily_actual_1.filled_impressions + daily_actual_2.filled_impressions
      expect(first_item).to have_key :month_unfilled_impressions
      expect(first_item).to have_key :month_fill_rate
    end
  end

  describe '#daily_revenue_graph' do
    let!(:daily_actual_1) do
      create(:publisher_daily_actual, publisher: publisher, currency: currency, date: 25.hours.ago)
    end
    let!(:daily_actual_2) do
      create(:publisher_daily_actual, publisher: publisher, currency: currency, date: Date.current)
    end

    subject { get :daily_revenue_graph, id: publisher.id }

    xit 'returns revenues info by dates' do
      subject
      expect(response).to have_http_status(200)
      expect(response_body).to be_a_kind_of Array
      expect(response_body[0][:date]).to eq daily_actual_1.date.to_s
      expect(response_body[0][:revenue]).to eq daily_actual_1.total_revenue
      expect(response_body[1][:date]).to eq daily_actual_2.date.to_s
      expect(response_body[1][:revenue]).to eq daily_actual_2.total_revenue
    end
  end

  describe '#show' do
    it 'returns publisher fields' do
      publisher  = create(
        :publisher,
        name: 'Amazon',
        company: company,
        client: client,
        publisher_stage: publisher_stage,
        type: publisher_type_option,
        estimated_monthly_impressions: 2_000,
        actual_monthly_impressions: 1_000
      )

      get :show, id: publisher.id

      expect(response_body[:id]).to eq publisher.id
      expect(response_body[:name]).to eq publisher.name
      expect(response_body[:comscore]).to eq publisher.comscore
      expect(response_body[:website]).to eq publisher.website
      expect(response_body[:estimated_monthly_impressions]).to eq publisher.estimated_monthly_impressions
    end
  end

  private

  def response_body
    @_response_body ||= JSON.parse(response.body, symbolize_names: true)
  end

  def first_item
    @_first_item ||= response_body.first
  end

  def response_body_member_ids
    response_body[:members].map { |member| member[:id] }
  end

  def response_body_contact_ids
    response_body[:contacts].map { |contact| contact[:id] }
  end

  def company
    @_company ||= create(:company)
  end

  def type_field
    @_type_field ||=
    create(
      :field, 
        subject_type: 'Publisher',
        name: 'Publisher Type',
        value_type: 'Option',
        locked: true
    )
  end

  def client
    @_client ||= create(:client, :advertiser, company: company)
  end

  def publisher_stage
    @_publisher_stage ||= create(:publisher_stage, company: company, sales_stage: sales_stage)
  end

  def sales_stage
    @_sales_stage ||= create(:sales_stage, company: company)
  end

  def publisher_type_option
    @_publisher_type_option ||= create(:option, company: company, name: 'PUBLISHER TYPE 1', field: type_field)
  end

  def user
    @_user ||= create(:user, company: company)
  end

  def publisher_custom_field_name
    @_publisher_custom_field_name ||=
      create(
        :publisher_custom_field_name,
        company: company,
        field_label: 'Last release date',
        field_type: 'text',
        field_index: 1,
        position: 1
      )
  end

  def publisher_custom_field_option
    @_publisher_custom_field_option ||=
      create(:publisher_custom_field_option, publisher_custom_field_name: publisher_custom_field_name)
  end

  def currency
    @currency ||= Currency.first || create(:currency)
  end
end
