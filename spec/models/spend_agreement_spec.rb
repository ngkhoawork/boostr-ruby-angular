require 'rails_helper'

describe SpendAgreement, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:company) }
    it { is_expected.to belong_to(:holding_company) }

    it { is_expected.to have_many(:spend_agreement_deals) }
    it { is_expected.to have_many(:spend_agreement_clients) }
    it { is_expected.to have_many(:spend_agreement_publishers) }

    it { is_expected.to have_many(:deals).through(:spend_agreement_deals) }
    it { is_expected.to have_many(:ios).through(:deals) }
    it { is_expected.to have_many(:clients).through(:spend_agreement_clients) }
    it { is_expected.to have_many(:parent_companies).through(:spend_agreement_parent_companies) }
    it { is_expected.to have_many(:publishers).through(:spend_agreement_publishers) }
  end

  context 'after_save' do
    context 'clients' do
      it 'assigns clients' do
        spend_agreement

        expect(spend_agreement.reload.clients.order(:created_at)).to eq [advertiser, agency]
      end

      it 'unlinks clients' do
        spend_agreement

        spend_agreement.update(client_ids: [])

        expect(spend_agreement.reload.clients).to eq []
      end

      it 'adds new clients' do
        spend_agreement

        spend_agreement.update(client_ids: [advertiser.id, agency.id, new_advertiser.id])

        expect(spend_agreement.reload.clients.order(:created_at).ids).to eq [advertiser.id, agency.id, new_advertiser.id]
      end

      it 'removes clients' do
        spend_agreement

        spend_agreement.update(client_ids: [advertiser.id])

        expect(spend_agreement.reload.clients.ids).to eq [advertiser.id]
      end
    end

    context 'parent_companies' do
      it 'assigns parent_companies' do
        spend_agreement(opts: {parent_companies_ids: [new_advertiser.id]})

        expect(spend_agreement.reload.parent_companies.ids).to eq [new_advertiser.id]
      end
    end

    context 'publishers' do
      it 'assigns publishers' do
        spend_agreement(opts: {publishers_ids: [publisher.id]})

        expect(spend_agreement.reload.publishers.ids).to eq [publisher.id]
      end
    end
  end

  def spend_agreement(opts: {})
    defaults = {
      company_id: company.id,
      client_ids: [advertiser.id, agency.id]
    }

    @_spend_agreement ||= create :spend_agreement, defaults.merge(opts)
  end

  def advertiser
    @advertiser ||= create :client, :advertiser,  company: company
  end

  def new_advertiser
    @new_advertiser ||= create :client, :advertiser, company: company
  end

  def agency
    @agency ||= create :client, :agency,  company: company
  end

  def company
    @company ||= create :company
  end

  def publisher
    @publisher ||= create :publisher, company: company
  end
end
