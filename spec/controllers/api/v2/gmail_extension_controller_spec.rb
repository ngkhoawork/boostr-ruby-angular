require 'rails_helper'

RSpec.describe Api::V2::GmailExtensionController, type: :controller do
  let(:company) { create :company }
  let(:user) { create :user, company: company }

  describe 'GET #index user authorized' do
    before do
      valid_token_auth user
    end

    it 'should return gmail template' do
      get :index

      expect(subject).to render_template('api/v2/gmail_extension/index')
    end
  end

  describe 'GET #index user NOT authorized' do
    it 'should NOT return gmail layout' do
      get :index

      expect(subject).to_not render_template('api/v2/gmail_extension/index')
    end
  end
end