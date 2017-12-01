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

  private

  def response_body
    @_response_body ||= JSON.parse(response.body, symbolize_names: true)
  end

  def first_item
    @_first_item ||= response_body.first
  end

  def company
    @_company ||= create(:company)
  end

  def type_field
    @_type_field ||= company.fields.where(subject_type: 'Publisher', name: 'Publisher Type').last
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
end
