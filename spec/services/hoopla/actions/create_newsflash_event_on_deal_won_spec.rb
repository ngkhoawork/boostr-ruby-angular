require 'rails_helper'

describe Hoopla::Actions::CreateNewsflashEventOnDealWon, vcr: true do
  describe '#perform' do
    let!(:hoopla_configuration) do
      create(:hoopla_configuration, company: company).tap do |hi|
        hi.create_hoopla_details!
        hi.hoopla_details.update_columns(
          credentials.merge(deal_won_newsflash_href: 'https://api.hoopla.net/newsflashes/newsflash_id')
        )
        hi.update_columns(switched_on: true)
      end
    end

    subject { described_class.new(company_id: company.id, deal_id: deal.id, user_id: user.id).perform }

    context 'when credentials are valid' do
      let(:credentials) { { client_id: 'CLIENT_ID', client_secret: 'CLIENT_SECRET' } }

      it 'must return true' do
        expect(subject).to eq true
      end
    end

    context 'when credentials are invalid' do
      let(:credentials) { { client_id: 'BAD_CLIENT_ID', client_secret: 'BAD_CLIENT_SECRET' } }

      it 'must raise auth error' do
        expect{subject}.to raise_error(Hoopla::Errors::AuthFailed)
      end
    end
  end

  private

  def company
    @_company ||= create(:company)
  end

  def advertiser
    @_advertiser ||= create(:client, :advertiser, company: company)
  end

  def deal
    @_deal ||= create(:deal, company: company, advertiser: advertiser)
  end

  def user
    @_user ||= create(:user, company: company, is_legal: true).tap do |user|
      create(:hoopla_user, user: user, href: 'https://api.hoopla.net/users/user_id')
    end
  end
end
