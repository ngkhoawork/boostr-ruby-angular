require 'rails_helper'

RSpec.describe Api::SpendAgreementPublishersController, type: :controller do
  let(:company) { create :company }
  let(:user) { create :user, company: company }

  before do
    sign_in user
  end

  describe "GET #index" do
    it "returns http success" do
      get :index, spend_agreement_id: sa.id
      expect(response).to be_success
    end
  end

  describe "POST #create" do
    it "creates a record" do
      expect{
        post :create, spend_agreement_id: sa.id, spend_agreement_publisher: spend_agreement_publisher_params
      }.to change(SpendAgreementPublisher, :count).by(1)
    end
  end

  describe "DELETE #destroy" do
    it 'deletes the record' do
      spend_agreement_publisher = create :spend_agreement_publisher, publisher: publisher, spend_agreement: sa

      expect {
        delete :destroy, spend_agreement_id: sa.id, id: spend_agreement_publisher.id
      }.to change(SpendAgreementPublisher, :count).by -1
    end
  end

  def sa(opts={})
    defaults = {
      company: company
    }
    @_sa ||= create :spend_agreement, defaults.merge(opts)
  end

  def spend_agreement_publisher_params
    {publisher_id: publisher.id}
  end

  def publisher
    @_publisher ||= create :publisher, company: company
  end
end
