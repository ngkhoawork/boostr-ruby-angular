require 'rails_helper'

RSpec.describe Api::SpendAgreementTeamMembersController, type: :controller do
  let(:company) { create :company }
  let(:user) { create :user, company: company }

  before do
    sign_in user
    role_field
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
        post :create, spend_agreement_id: sa.id, spend_agreement_team_member: spend_agreement_team_member_params
      }.to change(SpendAgreementTeamMember, :count).by(1)
    end
  end

  describe 'PUT #update' do
    it "creates a record" do
      team_member = create  :spend_agreement_team_member, spend_agreement: sa

      put :update, id: team_member.id,
          spend_agreement_id: sa.id,
          spend_agreement_team_member: {values_attributes: [option_id: role_option.id, field_id: role_field.id]},
          format: :json

      expect(json_response['role']).to eq role_option.name
    end
  end

  describe "DELETE #destroy" do
    it 'deletes the record' do
      team_member = create :spend_agreement_team_member, user: user, spend_agreement: sa

      expect {
        delete :destroy, spend_agreement_id: sa.id, id: team_member.id
      }.to change(SpendAgreementTeamMember, :count).by -1
    end
  end

  def sa(opts={})
    defaults = {
      company: company
    }
    @_sa ||= create :spend_agreement, defaults.merge(opts)
  end

  def spend_agreement_team_member_params
    {user_id: user.id}
  end

  def advertiser
    @advertiser ||= create :client, :advertiser
  end

  def agency
    @agency ||= create :client, :agency
  end

  def role_field
    @role_field ||= company.fields.find_or_create_by(subject_type: 'Multiple', name: 'Spend Agreement Member Role', value_type: 'Option', locked: true)
  end

  def role_option
    @role_option ||= create :option, field: role_field
  end
end
