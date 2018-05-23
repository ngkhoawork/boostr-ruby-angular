require 'rails_helper'

describe SpendAgreementTrackingService do
  let!(:company) { create :company }
  let(:subject) { SpendAgreementTrackingService.new(spend_agreement: sa) }

  describe '#track_deals' do
    context 'tracks' do
      it 'deal advertiser via child brand' do

        deal = create_deals(1, { agency: nil}).first
        sa({client_ids: [advertiser.id]})

        expect(deal.spend_agreements.count).to be 1
      end

      it 'deal child via parent relation' do
        advertiser(parent_client: parent_company)
        deal = create_deals(1, { agency: nil}).first
        sa({client_ids: [], parent_companies_ids: [parent_company.id]})

        expect(deal.spend_agreements.count).to be 1
      end

      it 'deal child via parent and child relation' do
        advertiser(parent_client: parent_company)
        deal = create_deals(1, { agency: nil}).first
        sa({client_ids: [advertiser.id], parent_companies_ids: [parent_company.id]})

        expect(deal.spend_agreements.count).to be 1
      end

      it 'deal with child of parent and agency' do
        advertiser(parent_client: parent_company)
        deal = create_deals.first
        sa({ client_ids: [advertiser.id], parent_companies_ids: [parent_company.id]})

        expect(deal.spend_agreements.count).to be 1
      end

      it 'deal with agreement parent as advertiser' do
        deal = create_deals(1, { advertiser: parent_company, agency: nil }).first

        sa({ client_ids: [], parent_companies_ids: [parent_company.id]})

        expect(deal.spend_agreements.count).to be 1
      end

      it 'deal with agency and agreement parent as advertiser' do
        deal = create_deals(1, { advertiser: parent_company }).first
        sa({ client_ids: [], parent_companies_ids: [parent_company.id]})

        expect(deal.spend_agreements.count).to be 1
      end

      it 'deal with agency and agreement parent as advertiser' do
        advertiser(parent_client: parent_company)

        deal = create_deals(1, { advertiser: advertiser }).first
        sa({ client_ids: [], parent_companies_ids: [parent_company.id]})

        expect(deal.spend_agreements.count).to be 1
      end

      it 'deal with an agency and advertiser full match' do
        deal = create_deals(1, { agency: agency, advertiser: advertiser }).first
        sa({ client_ids: [advertiser.id, agency.id] })

        expect(deal.spend_agreements.count).to be 1
      end

      it 'deal with an agency and advertiser and agreement has a parent, agency and advertiser' do
        advertiser(parent_client: parent_company)

        deal = create_deals(1, { agency: agency, advertiser: advertiser }).first
        sa({ client_ids: [advertiser.id, agency.id], parent_companies_ids: [parent_company.id]})

        expect(deal.spend_agreements.count).to be 1
      end

      it 'deal with an agency and advertiser and agreement has a parent, agency and advertiser' do
        advertiser(parent_client: parent_company)

        deal = create_deals(1, { agency: agency, advertiser: advertiser }).first
        sa({ client_ids: [agency.id], parent_companies_ids: [parent_company.id]})

        expect(deal.spend_agreements.count).to be 1
      end

      it 'deal with holding company of that agency' do
        agency(holding_company: holding_company)

        deal = create_deals.first
        sa({client_ids: [], holding_company: holding_company })

        expect(deal.spend_agreements.count).to be 1
      end
    end

    context 'does not track' do
      it 'deal with child of parent but different child is specified' do
        advertiser(parent_client: parent_company)
        new_advertiser(parent_client: parent_company)
        deal = create_deals(1, { agency: nil }).first
        sa({ client_ids: [new_advertiser.id], parent_companies_ids: [parent_company.id]})

        expect(deal.spend_agreements.count).to be 0
      end

      it 'deal with child of parent but different child is specified' do
        advertiser(parent_client: parent_company)
        deal = create_deals(1, { agency: nil, advertiser: parent_company }).first
        sa({ client_ids: [advertiser.id], parent_companies_ids: [parent_company.id]})

        expect(deal.spend_agreements.count).to be 0
      end

      it 'deal with parent and agency but agreement has child' do
        advertiser(parent_client: parent_company)

        deal = create_deals(1, { advertiser: parent_company }).first
        sa({ client_ids: [advertiser.id], parent_companies_ids: [parent_company.id]})

        expect(deal.spend_agreements.count).to be 0
      end

      it 'deal with no children of agreement parent with children' do
        new_advertiser(parent_client: parent_company)

        deal = create_deals(1, { advertiser: advertiser }).first
        sa({ client_ids: [], parent_companies_ids: [parent_company.id]})

        expect(deal.spend_agreements.count).to be 0
      end

      it 'deal with no children of agreement parent' do
        deal = create_deals(1, { advertiser: advertiser }).first
        sa({ client_ids: [], parent_companies_ids: [parent_company.id]})

        expect(deal.spend_agreements.count).to be 0
      end

      it 'deal without agreement agency' do
        deal = create_deals(1, { agency: nil, advertiser: advertiser }).first
        sa({ client_ids: [agency.id] })

        expect(deal.spend_agreements.count).to be 0
      end

      it 'deal without agreement agency when agreement has deal advertiser' do
        deal = create_deals(1, { agency: nil, advertiser: advertiser }).first
        sa({ client_ids: [advertiser.id, agency.id] })

        expect(deal.spend_agreements.count).to be 0
      end

      it 'deal without agreement agency when agreement has deal advertiser and agency' do
        advertiser(parent_client: parent_company)

        deal = create_deals(1, { agency: nil, advertiser: advertiser }).first
        sa({ client_ids: [advertiser.id, agency.id], parent_companies_ids: [parent_company.id]})

        expect(deal.spend_agreements.count).to be 0
      end

      it 'deal without agreement agency when agreement has deal agency' do
        advertiser(parent_client: parent_company)

        deal = create_deals(1, { agency: nil, advertiser: advertiser }).first
        sa({ client_ids: [agency.id], parent_companies_ids: [parent_company.id]})

        expect(deal.spend_agreements.count).to be 0
      end

      it 'deal with different holding company of agency' do
        deal = create_deals.first

        sa({ client_ids: [], holding_company: holding_company })

        expect(deal.spend_agreements.count).to be 0
      end
    end

    it 'does not add deals when manually tracked' do
      create_list :deal, 3, agency: agency, advertiser: advertiser

      expect(sa(manually_tracked: true).deals.count).to eq 0
    end

    it 'does not track non-matching deals' do
      create_deals(3)
      create :deal

      expect(sa.deals.count).to eq 3
    end
  end

  describe '#track_spend_agreements' do
    context 'deal with advertiser and no agency' do
      it 'tracks agreement with only an advertiser' do
        sa({client_ids: [advertiser.id]})
        deal = create_deals(1, { agency: nil}).first

        expect(deal.spend_agreements.count).to be 1
      end

      it 'tracks agreement with a parent of advertiser and no child brands' do
        advertiser(parent_client: parent_company)
        sa({client_ids: [], parent_companies_ids: [parent_company.id]})

        deal = create_deals(1, { agency: nil}).first

        expect(deal.spend_agreements.count).to be 1
      end

      it 'tracks agreement with a parent of advertiser and advertiser child' do
        advertiser(parent_client: parent_company)
        sa({client_ids: [advertiser.id], parent_companies_ids: [parent_company.id]})

        deal = create_deals(1, { agency: nil}).first

        expect(deal.spend_agreements.count).to be 1
      end

      it 'tracks agreement with deal advertiser as parent company' do
        sa({client_ids: [], parent_companies_ids: [parent_company.id]})

        deal = create_deals(1, { agency: nil, advertiser: parent_company }).first

        expect(deal.spend_agreements.count).to be 1
      end

      it 'does not track agreement with a parent and other advertiser' do
        advertiser(parent_client: parent_company)
        sa({client_ids: [new_advertiser.id], parent_companies_ids: [parent_company.id]})

        deal = create_deals(1, { agency: nil}).first

        expect(deal.spend_agreements.count).to be 0
      end

      it 'does not track agreement with child when deal is for parent' do
        advertiser(parent_client: parent_company)
        sa({client_ids: [advertiser.id], parent_companies_ids: [parent_company.id]})

        deal = create_deals(1, { agency: nil, advertiser: parent_company}).first

        expect(deal.spend_agreements.count).to be 0
      end

      it 'does not track agreement with agency but no children' do
        sa({client_ids: [agency.id]})

        deal = create_deals(1, { agency: nil }).first

        expect(deal.spend_agreements.count).to be 0
      end

      it 'does not track agreement with agency and children' do
        sa({client_ids: [agency.id, advertiser.id]})

        deal = create_deals(1, { agency: nil }).first

        expect(deal.spend_agreements.count).to be 0
      end

      it 'does not track agreement with agency, parent and children' do
        advertiser(parent_client: parent_company)
        sa({client_ids: [advertiser.id, agency.id], parent_companies_ids: [parent_company.id]})

        deal = create_deals(1, { agency: nil }).first

        expect(deal.spend_agreements.count).to be 0
      end

      it 'does not track agreement with agency and parent' do
        advertiser(parent_client: parent_company)
        sa({client_ids: [agency.id], parent_companies_ids: [parent_company.id]})

        deal = create_deals(1, { agency: nil }).first

        expect(deal.spend_agreements.count).to be 0
      end
    end

    context 'deal with advertiser and agency' do
      it 'tracks agreement by advertiser and agency with holding' do
        agency(holding_company: holding_company)
 
        sa({client_ids: [advertiser.id]})

        deal = create_deals.first

        expect(deal.spend_agreements.count).to be 1
      end

      it 'tracks agreement by advertiser and parent' do
        advertiser(parent_client: parent_company)
        sa({client_ids: [advertiser.id], parent_companies_ids: [parent_company.id]})

        deal = create_deals.first

        expect(deal.spend_agreements.count).to be 1
      end

      it 'tracks agreement by parent company' do
        advertiser(parent_client: parent_company)
        sa({client_ids: [], parent_companies_ids: [parent_company.id]})

        deal = create_deals(1, advertiser: parent_company, agency: agency).first

        expect(deal.spend_agreements.count).to be 1
      end

      it 'tracks agreement with a parent of advertiser and no child brands' do
        advertiser(parent_client: parent_company)
        sa({client_ids: [], parent_companies_ids: [parent_company.id]})

        deal = create_deals(1, { agency: agency}).first

        expect(deal.spend_agreements.count).to be 1
      end

      it 'tracks agreement with agency and children' do
        sa({client_ids: [advertiser.id, agency.id]})

        deal = create_deals.first

        expect(deal.spend_agreements.count).to be 1
      end

      it 'tracks agreement with parent, child and agency' do
        advertiser(parent_client: parent_company)
        sa({client_ids: [advertiser.id, agency.id], parent_companies_ids: [parent_company.id]})

        deal = create_deals.first

        expect(deal.spend_agreements.count).to be 1
      end

      it 'tracks agreement with parent and agency' do
        advertiser(parent_client: parent_company)
        sa({client_ids: [agency.id], parent_companies_ids: [parent_company.id]})

        deal = create_deals.first

        expect(deal.spend_agreements.count).to be 1
      end

      it 'tracks agreement with holding company of that agency' do
        agency(holding_company: holding_company)
        sa({client_ids: [advertiser.id], holding_company: holding_company })

        deal = create_deals.first

        expect(deal.spend_agreements.count).to be 1
      end

      it 'tracks agreement with holding company of that agency and no advertiser' do
        agency(holding_company: holding_company)
        sa({client_ids: [], holding_company: holding_company })

        deal = create_deals.first

        expect(deal.spend_agreements.count).to be 1
      end

      it 'tracks agreement with parent company and no advertiser' do
        advertiser(parent_client: parent_company)
        sa({client_ids: [], parent_companies_ids: [parent_company.id] })

        deal = create_deals.first

        expect(deal.spend_agreements.count).to be 1
      end

      it 'tracks agreement with agency but no children' do
        sa({client_ids: [agency.id]})

        deal = create_deals.first

        expect(deal.spend_agreements.count).to be 1
      end

      it 'does not track agreement with children by parent company' do
        advertiser(parent_client: parent_company)
        sa({client_ids: [advertiser.id], parent_companies_ids: [parent_company.id]})

        deal = create_deals(1, advertiser: parent_company, agency: agency).first

        expect(deal.spend_agreements.count).to be 0
      end

      it 'does not track agreement with different holding company of agency' do
        sa({client_ids: [], holding_company: holding_company})

        deal = create_deals.first

        expect(deal.spend_agreements.count).to be 0
      end

      it 'does not track holding company agreement with different brands' do
        agency(holding_company: holding_company)
        new_advertiser(parent_client: parent_company)
 
        sa({client_ids: [new_advertiser.id, agency.id], parent_companies_ids: [parent_company.id], holding_company: holding_company})

        deal = create_deals(1, advertiser: parent_company, agency: agency).first

        expect(deal.spend_agreements.count).to be 0
      end

      it 'does not track agreement with different agency and no holding' do
        sa({client_ids: [advertiser.id, new_agency.id] })

        deal = create_deals.first

        expect(deal.spend_agreements.count).to be 0
      end
    end
  end

  private

  def sa(opts={})
    defaults = {
      client_ids: [advertiser.id, agency.id],
      manually_tracked: false,
      start_date: Date.new(2017, 1, 1),
      end_date: Date.new(2017, 12, 31),
      holding_company: nil
    }

    @sa ||= create :spend_agreement, defaults.merge(opts)
  end

  def create_deals(count=1, opts={})
    defaults = {
      agency: agency,
      advertiser: advertiser,
      start_date: Date.new(2017, 1, 1),
      end_date: Date.new(2017, 12, 31),
      manual_update: true
    }

    create_list :deal, count, defaults.merge(opts)
  end

  def advertiser(opts={})
    @advertiser ||= create :client, :advertiser, opts
  end

  def agency(opts={})
    @agency ||= create :client, :agency, opts
  end

  def new_advertiser(opts={})
    @new_advertiser ||= create :client, :advertiser, :advertiser, opts
  end

  def new_agency(opts={})
    @new_agency ||= create :client, :agency, opts
  end

  def parent_company
    @parent_company ||= create :parent_client
  end

  def holding_company
    @_holding_company ||= create(:holding_company)
  end
end
