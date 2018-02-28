require 'rails_helper'

RSpec.describe Api::PmpMembersController, type: :controller do
  before do
    sign_in user
  end

  describe 'POST #create' do
    it 'creates a new pmp member and returns success' do
      expect do
        post :create, pmp_id: pmp.id, pmp_member: pmp_member_params, format: :json
        response_json = JSON.parse(response.body)
        expect(response).to be_success
      end.to change(PmpMember, :count).by(1)
    end

    it 'returns errors if parameters are invalid' do
      expect do
        post :create, pmp_id: pmp.id, pmp_member: { blah: 'blah' }, format: :json
        expect(response.status).to eq(422)
        response_json = JSON.parse(response.body)
        expect(response_json['errors']['share']).to eq(["can't be blank"])
      end.to_not change(PmpMember, :count)
    end
  end

  describe 'PUT #update' do
    it 'updates a pmp member successfully' do
      id = pmp_member.id
      put :update, pmp_id: pmp.id, id: id, pmp_member: { share: 50 }, format: :json
      expect(response).to be_success
      pmp_member = PmpMember.find(id)
      expect(pmp_member.share).to eq(50)
    end
  end

  describe 'DELETE #destroy' do
    it 'delete a pmp member' do
      pmp_member
      expect do
        delete :destroy, pmp_id: pmp.id, id: pmp_member.id, format: :json
        expect(response).to be_success
      end.to change(PmpMember, :count).by(-1)
    end
  end

  private

  def company
    @_company ||= create :company
  end

  def user
    @_user ||= create :user, company: company
  end

  def pmp
    @_pmp ||= create :pmp, company: company, name: 'programmatic'
  end

  def pmp_member
    @_pmp_member ||= create :pmp_member, pmp: pmp
  end

  def pmp_member_params
    @_pmp_member_params ||= build(:pmp_member).attributes.except('id', 'created_at', 'updated_at').symbolize_keys
  end
end
