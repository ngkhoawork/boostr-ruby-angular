require 'rails_helper'

RSpec.describe Api::EalertTemplatesController, type: :controller do
  let!(:ealert_template) { EalertTemplate::Contract.create!(company: company) }

  let(:params) { {} }

  before { sign_in user }

  describe '#show' do
    let(:params) { { type: 'contract' } }
    subject { get :show, params }

    it 'returns an ealert template' do
      subject

      expect(response).to be_success
      expect(response_body[:id]).to eq ealert_template.id
    end
  end

  describe '#update' do
    let(:attributes) do
      {
        recipients: [FFaker::Internet.email],
        fields_attributes: [
          { id: first_field.id, position: 1_000_000 }
        ]
      }
    end
    let(:params) { { type: 'contract', ealert_template: attributes } }

    subject { get :update, params }

    it do
      expect{subject}.to change{ealert_template.reload.recipients}.to(attributes[:recipients]).and \
                         change{first_field.reload.position}.to(1_000_000)
    end

    context 'when provided positions params are non-uniq' do
      let(:attributes) do
        {
          recipients: [FFaker::Internet.email],
          fields_attributes: [
            { id: first_field.id, position: 1 },
            { id: second_field.id, position: 1 }
          ]
        }
      end

      it { subject; expect(response_body[:errors][0]).to match /already exists/ }
    end
  end

  describe '#send_ealert' do
    let(:params) do
      {
        type: 'contract',
        subject_id: contract.id,
        recipients: [user.email],
        comment: FFaker::Lorem.phrase,
        attached_asset_ids: [contract_asset.id]
      }
    end

    subject { post :send_ealert, params }

    before { allow_any_instance_of(Asset).to receive(:presigned_url).and_return(FFaker::Internet.http_url) }

    it { expect(ContractMailer).to receive_message_chain(:ealert, :deliver_now); subject }
  end

  private

  def response_body
    @_response_body ||= JSON.parse(response.body, symbolize_names: true)
  end

  def user
    @_user ||= create(:user, company: company)
  end

  def company
    @_company ||= create(:company)
  end

  def first_field
    @_first_field ||= ealert_template.fields.order(created_at: :asc).first
  end

  def second_field
    @_second_field ||= ealert_template.fields.order(created_at: :asc).second
  end

  def contract
    @_contract ||= create(:contract, company: company, type: type_option)
  end

  def type_field
    @_type_field ||= create(:field, subject_type: 'Contract', name: 'Type', company: company)
  end

  def type_option
    @_type_option ||= create(:option, company: company, name: 'Contract Type 1', field: type_field)
  end

  def contract_asset
    @_contract_asset ||= create(:asset, attachable: contract)
  end
end
