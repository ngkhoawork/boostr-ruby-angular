require 'rails_helper'

describe Api::AdUnitsController do
  before { sign_in user }

  describe 'GET #index' do
    it 'assigns all api_ad_units as ad_units' do
      2.times { create :ad_unit, product: product }

      get :index, product_id: product

      expect(response).to be_success
      expect(response_json(response).length).to eq(2)
    end
  end

  describe 'GET #show' do
    it 'assigns the requested api_ad_unit as @api_ad_unit' do
      ad_unit = AdUnit.create! valid_attributes
      get :show, {:id => ad_unit.to_param}
      expect(assigns(:api_ad_unit)).to eq(ad_unit)
    end
  end

  describe 'GET #new' do
    it 'assigns a new api_ad_unit as @api_ad_unit' do
      get :new, {}
      expect(assigns(:api_ad_unit)).to be_a_new(AdUnit)
    end
  end

  describe 'GET #edit' do
    it 'assigns the requested api_ad_unit as @api_ad_unit' do
      ad_unit = AdUnit.create! valid_attributes
      get :edit, {:id => ad_unit.to_param}
      expect(assigns(:api_ad_unit)).to eq(ad_unit)
    end
  end

  describe 'POST #create' do
    context 'with valid params' do
      it 'creates a new Api::AdUnit' do
        expect {
          post :create, {:api_ad_unit => valid_attributes}
        }.to change(AdUnit, :count).by(1)
      end

      it 'assigns a newly created api_ad_unit as @api_ad_unit' do
        post :create, {:api_ad_unit => valid_attributes}
        expect(assigns(:api_ad_unit)).to be_a(AdUnit)
        expect(assigns(:api_ad_unit)).to be_persisted
      end

      it 'redirects to the created api_ad_unit' do
        post :create, {:api_ad_unit => valid_attributes}
        expect(response).to redirect_to(AdUnit.last)
      end
    end

    context 'with invalid params' do
      it 'assigns a newly created but unsaved api_ad_unit as @api_ad_unit' do
        post :create, {:api_ad_unit => invalid_attributes}
        expect(assigns(:api_ad_unit)).to be_a_new(AdUnit)
      end

      it 're-renders the new template' do
        post :create, {:api_ad_unit => invalid_attributes}
        expect(response).to render_template('new')
      end
    end
  end

  describe 'PUT #update' do
    context 'with valid params' do
      let(:new_attributes) {
        skip('Add a hash of attributes valid for your model')
      }

      it 'updates the requested api_ad_unit' do
        ad_unit = AdUnit.create! valid_attributes
        put :update, {:id => ad_unit.to_param, :api_ad_unit => new_attributes}
        ad_unit.reload
        skip('Add assertions for updated state')
      end

      it 'assigns the requested api_ad_unit as @api_ad_unit' do
        ad_unit = AdUnit.create! valid_attributes
        put :update, {:id => ad_unit.to_param, :api_ad_unit => valid_attributes}
        expect(assigns(:api_ad_unit)).to eq(ad_unit)
      end

      it 'redirects to the api_ad_unit' do
        ad_unit = AdUnit.create! valid_attributes
        put :update, {:id => ad_unit.to_param, :api_ad_unit => valid_attributes}
        expect(response).to redirect_to(ad_unit)
      end
    end

    context 'with invalid params' do
      it 'assigns the api_ad_unit as @api_ad_unit' do
        ad_unit = AdUnit.create! valid_attributes
        put :update, {:id => ad_unit.to_param, :api_ad_unit => invalid_attributes}
        expect(assigns(:api_ad_unit)).to eq(ad_unit)
      end

      it 're-renders the edit template' do
        ad_unit = AdUnit.create! valid_attributes
        put :update, {:id => ad_unit.to_param, :api_ad_unit => invalid_attributes}
        expect(response).to render_template('edit')
      end
    end
  end

  describe 'DELETE #destroy' do
    it 'destroys the requested api_ad_unit' do
      ad_unit = AdUnit.create! valid_attributes
      expect {
        delete :destroy, {:id => ad_unit.to_param}
      }.to change(AdUnit, :count).by(-1)
    end

    it 'redirects to the api_ad_units list' do
      ad_unit = AdUnit.create! valid_attributes
      delete :destroy, {:id => ad_unit.to_param}
      expect(response).to redirect_to(api_ad_units_url)
    end
  end

  private

  def company
    @_company ||= create :company
  end

  def user
    @_user ||= create :user, company: company
  end

  def ad_unit
    @_ad_unit ||= create :ad_unit, product: product
  end

  def product
    @_product ||= create :product, company: company
  end
end
