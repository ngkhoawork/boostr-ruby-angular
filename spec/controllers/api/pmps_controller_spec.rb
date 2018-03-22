require 'rails_helper'

RSpec.describe Api::PmpsController, type: :controller do
  before do
    sign_in user
  end

  describe 'GET #index' do
    it 'returns a list of pmps' do
      create_list :pmp, 3, company: company

      get :index, format: :json
      expect(response).to be_success
      response_json = JSON.parse(response.body)
      expect(response_json.length).to eq(3)
    end
  end

  describe 'GET #show' do
    it 'returns json for a pmp' do
      get :show, id: pmp.id, format: :json
      expect(response).to be_success
      response_json = JSON.parse(response.body)
      expect(response_json['name']).to eq('programmatic')
    end
  end

  describe 'POST #create' do
    it 'creates a new pmp and returns success' do
      expect do
        post :create, pmp: pmp_params, format: :json
        expect(response).to be_success
      end.to change(Pmp, :count).by(1)
    end

    it 'returns errors if parameters are invalid' do
      expect do
        post :create, pmp: { blah: 'blah' }, format: :json
        expect(response.status).to eq(422)
        response_json = JSON.parse(response.body)
        expect(response_json['errors']['name']).to eq(["can't be blank"])
      end.to_not change(Pmp, :count)
    end
  end

  describe 'PUT #update' do
    it 'updates a pmp successfully' do
      put :update, id: pmp.id, pmp: { name: 'New Name' }, format: :json
      expect(response).to be_success
      response_json = JSON.parse(response.body)
      expect(response_json['name']).to eq('New Name')
    end
  end

  describe 'DELETE #destroy' do
    context 'user without admin role' do
      it 'can not delete a pmp' do
        delete :destroy, id: pmp.id, format: :json
        response_json = JSON.parse(response.body)
        expect(response_json['error']).to eq("You can't delete pmp")
      end
    end

    context 'user with admin role' do
      before { sign_in admin }
      it 'delete a pmp by admin' do
        pmp
        expect do
          delete :destroy, id: pmp.id, format: :json
          expect(response).to be_success
        end.to change(Pmp, :count).by(-1)
      end
    end
  end

  private

  def company
    @_company ||= create :company
  end

  def user
    @_user ||= create :user, company: company
  end

  def admin
    @_admin ||= create :user, company: company, roles: ['admin']
  end

  def pmp
    @_pmp ||= create :pmp, company: company, name: 'programmatic'
  end

  def pmp_params
    @_pmp_params ||= attributes_for :pmp
  end
end
