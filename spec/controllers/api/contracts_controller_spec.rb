require 'rails_helper'

RSpec.describe Api::ContractsController, type: :controller do
  let!(:contract) { create(:contract, company: company) }
  let(:params) { {} }

  before { sign_in user }

  describe '#index' do

    subject { get :index, params }

    it 'returns a list of contracts' do
      subject

      expect(response).to be_success
      expect(response_body).to be_a_kind_of Array
      expect(first_item[:id]).to eq contract.id
    end
  end

  describe '#show' do
    let(:params) { { id: contract.id } }
    subject { get :show, params }

    it 'returns a contract' do
      subject

      expect(response).to be_success
      expect(response_body[:id]).to eq contract.id
    end
  end

  describe '#create' do
    let(:attributes) { attributes_for(:contract) }
    let(:params) { { contract: attributes } }

    subject { post :create, params }

    it 'creates a contract' do
      expect{subject}.to change{Contract.count}.by(1)
      expect(response).to have_http_status(201)
      expect(response_body[:id]).to eq Contract.last.id
    end

    context 'when type, status params are included in existing options' do
      let(:attributes) { super().merge!(type_id: type_option.id, status_id: status_option.id) }

      it { expect{subject}.to change{Contract.count}.by(1) }
    end
  end

  describe '#update' do
    let(:attributes) { { name: FFaker::Lorem.word } }
    let(:params) { { id: contract.id, contract: attributes } }

    subject { put :update, params }

    it 'updates a contract' do
      expect{subject}.to change{contract.reload.name}.to(params[:contract][:name])
      expect(response).to have_http_status(200)
      expect(response_body[:id]).to eq Contract.last.id
    end

    context 'when type, status params are included in existing options' do
      let(:attributes) { super().merge!(type_id: type_option.id, status_id: status_option.id) }

      it do
        expect{subject}.to change{contract.reload.type_id}.to(type_option.id).and \
                           change{contract.reload.status_id}.to(status_option.id)
      end
    end
  end

  describe '#destroy' do
    it 'delete contract' do
      expect{
        delete :destroy, id: contract.id
      }.to change{Contract.count}.by(-1)
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

  def user
    @_user ||= create(:user, company: company) # @_user ||= create(:user, company: company, team: team)
  end

  def type_field
    @_type_field ||= company.fields.find_by!(subject_type: 'Contract', name: 'Type')
  end

  def type_option
    @_type_option ||= create(:option, company: company, name: 'Contract Type 1', field: type_field)
  end

  def status_field
    @_status_field ||= company.fields.find_by!(subject_type: 'Contract', name: 'Status')
  end

  def status_option
    @_status_option ||= create(:option, company: company, name: 'Contract Status 1', field: status_field)
  end
end
