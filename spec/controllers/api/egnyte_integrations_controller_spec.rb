require 'rails_helper'

RSpec.describe Api::EgnyteIntegrationsController, type: :controller do

  let(:company) { create(:company) }
  let(:user) { create(:user, company: company) }

  before { sign_in user }

  describe '#show' do
    subject { get :show }

    context 'when resource is present' do
      let!(:egnyte_integration) { company.create_egnyte_integration! }

      it do
        subject
        expect(response).to have_http_status(200)
        expect(response_body[:id]).to eq egnyte_integration.id
      end
    end

    context 'when resource is absent' do
      it do
        subject
        expect(response).to have_http_status(404)
      end
    end
  end

  describe '#create' do
    let(:params) do
      {
        egnyte_integration: {
          app_domain: 'example.com'
        }
      }
    end
    subject { post :create, params }

    it do
      expect{subject}.to change{EgnyteIntegration.count}.by(1)
      expect(response).to have_http_status(201)
      expect(response_body[:id]).to eq EgnyteIntegration.last.id
    end
  end

  describe '#update' do
    let(:params) do
      {
        egnyte_integration: {
          app_domain: 'example.com'
        }
      }
    end
    subject { put :update, params }

    context 'when resource is present' do
      let!(:egnyte_integration) { company.create_egnyte_integration! }

      it do
        expect{subject}.to change{egnyte_integration.reload.app_domain}.to(params[:egnyte_integration][:app_domain])
        expect(response).to have_http_status(200)
        expect(response_body[:id]).to eq egnyte_integration.id
      end
    end

    context 'when resource is absent' do
      it do
        subject
        expect(response).to have_http_status(404)
      end
    end
  end

  describe '#oauth_settings' do
    subject { get :oauth_settings }

    context 'when resource is present' do
      let!(:egnyte_integration) { company.create_egnyte_integration! }

      context 'and its app_domain is present' do
        before(:each) { egnyte_integration.update(app_domain: 'example.com', enabled: true) }

        it do
          subject
          expect(response).to have_http_status(200)
          expect(response_body[:egnyte_login_uri]).not_to be_nil
        end
      end

      context 'but it is not enabled' do
        it do
          subject
          expect(response).to have_http_status(400)
          expect(response_body[:errors]).to include 'must be enabled'
        end
      end
    end

    context 'when resource is absent' do
      it do
        subject
        expect(response).to have_http_status(404)
      end
    end
  end

  private

  def response_body
    @_response_body ||= JSON.parse(response.body, symbolize_names: true)
  end
end
