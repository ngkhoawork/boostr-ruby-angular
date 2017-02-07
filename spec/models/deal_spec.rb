require 'rails_helper'

RSpec.describe Deal, type: :model do
  let(:company) { Company.first }
  let(:user) { create :user }

  context 'associations' do
    it { should have_many(:contacts).through(:deal_contacts) }
    it { should have_many(:deal_contacts) }
  end

  context 'scopes' do

    context 'for_client' do
      let!(:deal) { create :deal }
      let(:agency) { create :client }
      let!(:another_deal) { create :deal, agency: agency }

      it 'returns all when client_id is nil' do
        expect(Deal.for_client(nil).count).to eq(2)
      end

      it 'returns only the contacts that belong to the client_id' do
        expect(Deal.for_client(agency.id).count).to eq(1)
      end
    end

    context 'for_time_period' do
      let(:time_period) { create :time_period, start_date: '2015-01-01', end_date: '2015-12-31' }
      let!(:in_deal) { create :deal, start_date: '2015-02-01', end_date: '2015-2-28'  }
      let!(:out_deal) { create :deal, start_date: '2016-02-01', end_date: '2016-2-28'  }

      it 'should return deals that are completely in the time period' do
        expect(Deal.for_time_period(time_period.start_date, time_period.end_date).count).to eq(1)
        expect(Deal.for_time_period(time_period.start_date, time_period.end_date)).to include(in_deal)
      end

      it 'returns deals that are partially in the time period' do
        create :deal, start_date: '2015-02-01', end_date: '2016-2-28'
        create :deal, start_date: '2014-12-01', end_date: '2015-2-28'

        expect(Deal.for_time_period(time_period.start_date, time_period.end_date).count).to eq(3)
      end
    end

    context 'open' do
      let(:closed_stage) { create :stage, open: false }
      let(:open_stage) { create :stage, open: true }
      let!(:open_deal) { create :deal, stage: open_stage }
      let!(:closed_deal) { create :deal, stage: closed_stage }

      it 'returns only deals that have an open stage' do
        expect(Deal.all.length).to eq(2)
        expect(Deal.open.length).to eq(1)
        expect(Deal.open).to include(open_deal)
      end
    end
  end

  describe '#in_period_amt' do
    let(:deal) { create :deal }
    let(:product) { create :product }
    let(:time_period) { create :time_period, start_date: '2015-01-01', end_date: '2015-01-31' }

    it 'returns 0 when there are no deal products' do
      expect(deal.in_period_amt(time_period.start_date, time_period.end_date)).to eq(0)
    end

    it 'returns the whole budget of a deal product when the deal product is wholly within the same time period' do
      single_month_deal = create :deal, start_date: '2015-01-01', end_date: '2015-01-31'
      create :deal_product, deal: single_month_deal, product: product, budget: 1000

      expect(single_month_deal.in_period_amt(time_period.start_date, time_period.end_date)).to eq(1000)
    end

    it 'returns the whole budget of a deal product when the deal product is wholly within the same time period' do
      two_month_deal = create :deal, start_date: '2015-01-27', end_date: '2015-02-05'
      create :deal_product, deal: two_month_deal, product: product, budget: 1000

      expect(two_month_deal.in_period_amt(time_period.start_date, time_period.end_date)).to eq(500)
    end
  end

  describe '#days' do
    let(:deal) { create :deal, start_date: Date.new(2015, 1, 1), end_date: Date.new(2015, 1, 31) }

    it 'returns the number of days between the start and end dates.' do
      expect(deal.days).to eq(31)
    end
  end

  describe '#months' do
    let(:deal) { create :deal,  start_date: Date.new(2015, 9, 25), end_date: Date.new(2015, 12, 28) }

    it 'returns an array of parseable month and year data' do
      expected = [[2015, 9], [2015, 10], [2015, 11], [2015, 12]]
      expect(deal.months).to eq(expected)
    end
  end

  describe '#days_per_month' do
    it 'creates an array with the months mapped out in their days' do
      deal = build :deal, start_date: Date.new(2015, 9, 25), end_date: Date.new(2015, 12, 28)
      expect(deal.days_per_month).to eq([6, 31, 30, 28])
    end

    it 'creates an array with the months mapped out in their days' do
      deal = build :deal, start_date: Date.new(2015, 8, 15), end_date: Date.new(2015, 9, 30)
      expect(deal.days_per_month).to eq([17, 30])
    end

    it 'creates an array with the months mapped out in their days with a short period' do
      deal = build :deal, start_date: Date.new(2015, 9, 25), end_date: Date.new(2015, 9, 30)
      expect(deal.days_per_month).to eq([6])
    end

    it 'creates an array with the months mapped out in their days with a short period' do
      deal = build :deal, start_date: Date.new(2015, 9, 25), end_date: Date.new(2015, 10, 15)
      expect(deal.days_per_month).to eq([6, 15])
    end
  end

  describe '#reset_products' do
    let!(:deal) { create :deal }
    let!(:product) { create :product }
    let!(:deal_product) { create :deal_product, deal: deal, product: product }

    it 'deletes and recreates deal_product_budgets based on the start or end date changing' do
      expect do
        deal.update_attributes(end_date: Date.new(2015, 9, 29))
      end.to change(DealProductBudget, :count).by(1)
    end
  end

  describe '#generate_deal_members' do
    let(:client) { create :client }
    let!(:client_role_owner) { create :option, field: client_role_field(company), name: "Owner" }
    let(:role) { create :value, field: client_role_field(company), option: client_role_owner }
    let!(:client_member) { create :client_member, user: user, client: client, values: [role] }
    let(:deal) { build :deal, advertiser: client, company: company }

    it 'creates deal_members with defaults when creating a deal' do
      expect do
        deal.save
      end.to change(DealMember, :count).by(1)
      expect(DealMember.first.deal_id).to eq(deal.id)
      expect(DealMember.first.user_id).to eq(client_member.user_id)
      expect(DealMember.first.values.first.option_id).to eq(role.option_id)
      expect(DealMember.first.share).to eq(client_member.share)
    end

    context 'when there are no client members' do
      let!(:client_wo_members) { create :client }
      let!(:deal) { build :deal, advertiser: client_wo_members, creator: user, company: company }

      it 'assigns 100 percent share to the deal creator' do
        expect do
          deal.save
        end.to change(DealMember, :count).by(1)
        expect(deal.deal_members.count).to be(1)
        expect(deal.deal_members.first.user_id).to be(user.id)
        expect(deal.deal_members.first.share).to be(100)
      end
    end
  end

  context 'to_zip' do
    let(:deal) { create :deal, name: 'Bob' }
    let(:product) { create :product }
 
    it 'returns the contents of deal zip' do
      deal.deal_products.create(product_id: product.id, budget: 10_000)
      deal_zip = Deal.to_zip
      expect(deal_zip).not_to be_nil
    end
  end

  describe '#import' do
    let!(:user) { create :user }
    let!(:another_user) { create :user }
    let!(:company) { user.company }
    let!(:stage_100) { create :stage, company: user.company, name: 'Won', probability: 100, open: false }
    let!(:stage_100) { create :stage, company: user.company, name: 'Lost', probability: 0, open: false }
    let!(:advertiser) { create :client, created_by: user.id, client_type_id: advertiser_type_id(company) }
    let!(:agency) { create :client, created_by: user.id, client_type_id: agency_type_id(company) }
    let!(:deal_type_field) { user.company.fields.find_by_name('Deal Type') }
    let!(:deal_type) { create :option, field: deal_type_field, company: user.company }
    let!(:deal_source_field) { user.company.fields.find_by_name('Deal Source') }
    let!(:deal_source) { create :option, field: deal_source_field, company: user.company }
    let!(:close_reason_field) { user.company.fields.find_by_name('Close Reason') }
    let!(:close_reason) { create :option, field: close_reason_field, company: user.company }
    let!(:existing_deal) { create :deal, creator: another_user, updator: another_user }
    let!(:contacts) { create_list :contact, 4, company: company, client_id: advertiser.id }

    it 'creates a new deal from csv' do
      data = build :deal_csv_data
      expect do
        expect(Deal.import(generate_csv(data), user)).to eq([])
      end.to change(Deal, :count).by(1)

      deal = Deal.last
      expect(deal.name).to eq(data[:name])
      expect(deal.advertiser.name).to eq(data[:advertiser])
      expect(deal.agency.name).to eq(data[:agency])
      expect(deal.creator.email).to eq(user.email)
      expect(deal.updator.email).to eq(user.email)
      expect(deal.start_date).to eq(Date.parse(data[:start_date]))
      expect(deal.end_date).to eq(Date.parse(data[:end_date]))
      expect(deal.stage.name).to eq(data[:stage])
      expect(deal.users.map(&:email)).to eq([data[:team].split('/')[0]])
      expect(deal.deal_members.map(&:share)).to eq([data[:team].split('/')[1].to_i])
      expect(deal.created_at).to eq(data[:created])
      expect(deal.closed_at).to eq(Date.parse(data[:closed_date]))
      expect(deal.contacts.map(&:address).map(&:email).sort).to eq(data[:contacts].split(';').sort)
    end

    it 'creates a deal with type and source' do
      data = build :deal_csv_data, type: deal_type.name, source: deal_source.name
      expect(Deal.import(generate_csv(data), user)).to eq([])
      deal = Deal.last

      expect(deal.values.where(field: deal_type_field).first.option_id).to eq deal_type.id
      expect(deal.values.where(field: deal_source_field).first.option_id).to eq deal_source.id
    end

    it 'updates a deal by an ID match' do
      data = build :deal_csv_data, id: existing_deal.id
      expect do
        expect(Deal.import(generate_csv(data), user)).to eq([])
      end.not_to change(Deal, :count)
      existing_deal.reload

      expect(existing_deal.name).to eq(data[:name])
      expect(existing_deal.advertiser.name).to eq(data[:advertiser])
      expect(existing_deal.agency.name).to eq(data[:agency])
      expect(existing_deal.creator.email).not_to eq(user.email)
      expect(existing_deal.updator.email).to eq(user.email)
      expect(existing_deal.start_date).to eq(Date.parse(data[:start_date]))
      expect(existing_deal.end_date).to eq(Date.parse(data[:end_date]))
      expect(existing_deal.stage.name).to eq(data[:stage])
      expect(existing_deal.users.map(&:email)).to include(data[:team].split('/')[0])
      expect(existing_deal.deal_members.map(&:share)).to include(data[:team].split('/')[1].to_i)
      expect(existing_deal.created_at).to eq(data[:created])
      expect(existing_deal.contacts.map(&:address).map(&:email).sort).to eq(data[:contacts].split(';').sort)
    end

    it 'sets closed_at date for existing deals' do
      data = build :deal_csv_data, id: existing_deal.id, stage: existing_deal.stage.name
      expect do
        expect(Deal.import(generate_csv(data), user)).to eq([])
      end.not_to change(Deal, :count)
      existing_deal.reload
      expect(existing_deal.closed_at).to eq(Date.parse(data[:closed_date]))
    end

    it 'allows creation date to be nil' do
      data = build :deal_csv_data, id: existing_deal.id, created: nil
      expect do
        expect(Deal.import(generate_csv(data), user)).to eq([])
      end.not_to change(Deal, :count)
    end

    it 'allows close date to be nil' do
      data = build :deal_csv_data, id: existing_deal.id, closed_date: nil
      expect do
        expect(Deal.import(generate_csv(data), user)).to eq([])
      end.not_to change(Deal, :count)
    end

    it 'creates a deal with close reason' do
      data = build :deal_csv_data, close_reason: close_reason.name
      expect(Deal.import(generate_csv(data), user)).to eq([])
      deal = Deal.last

      expect(deal.values.where(field: close_reason_field).first.option_id).to eq close_reason.id
    end

    it 'finds a deal by name match' do
      data = build :deal_csv_data, name: existing_deal.name
      expect do
        expect(Deal.import(generate_csv(data), user)).to eq([])
      end.not_to change(Deal, :count)
      existing_deal.reload

      expect(existing_deal.updator.email).to eq(user.email)
      expect(existing_deal.start_date).to eq(Date.parse(data[:start_date]))
      expect(existing_deal.end_date).to eq(Date.parse(data[:end_date]))
    end

    context 'invalid data' do
      let!(:duplicate_advertiser) { create :client, client_type_id: advertiser_type_id(user.company), company: company }
      let!(:duplicate_advertiser2) { create :client, client_type_id: advertiser_type_id(user.company), company: company, name: duplicate_advertiser.name }
      let!(:duplicate_agency) { create :client, client_type_id: agency_type_id(user.company), company: company }
      let!(:duplicate_agency2) { create :client, client_type_id: agency_type_id(user.company), company: company, name: duplicate_agency.name }
      let!(:duplicate_deal) { create :deal, name: existing_deal.name }

      it 'requires ID to match' do
        data = build :deal_csv_data, id: 0
        expect(
          Deal.import(generate_csv(data), user)
        ).to eq([row: 1, message: ["Deal ID #{data[:id]} could not be found"]])
      end

      it 'requires name to exist' do
        data = build :deal_csv_data, name: nil
        expect(
          Deal.import(generate_csv(data), user)
        ).to eq([row: 1, message: ["Deal name can't be blank"]])
      end

      it 'requires name to match no more than one deal' do
        data = build :deal_csv_data, name: duplicate_deal.name
        expect(
          Deal.import(generate_csv(data), user)
        ).to eq([row: 1, message: ["Deal name #{data[:name]} matched more than one deal record"]])
      end

      it 'requires advertiser to be present' do
        data = build :deal_csv_data
        data[:advertiser] = nil
        expect(
          Deal.import(generate_csv(data), user)
        ).to eq([{row: 1, message: ["Advertiser can't be blank"]}])
      end

      it 'requires advertiser to exist' do
        data = build :deal_csv_data, advertiser: 'N/A'
        expect(
          Deal.import(generate_csv(data), user)
        ).to eq([{row: 1, message: ["Advertiser #{data[:advertiser]} could not be found"]}])
      end

      it 'requires advertiser to match no more than 1 record' do
        data = build :deal_csv_data, advertiser: duplicate_advertiser2.name
        expect(
          Deal.import(generate_csv(data), user)
        ).to eq([{row: 1, message: ["Advertiser #{data[:advertiser]} matched more than one account record"]}])
      end

      it 'requires agency to exist' do
        data = build :deal_csv_data, agency: 'N/A'
        expect(
          Deal.import(generate_csv(data), user)
        ).to eq([{row: 1, message: ["Agency #{data[:agency]} could not be found"]}])
      end

      it 'requires agency to match no more than 1 record' do
        data = build :deal_csv_data, agency: duplicate_agency2.name
        expect(
          Deal.import(generate_csv(data), user)
        ).to eq([{row: 1, message: ["Agency #{data[:agency]} matched more than one account record"]}])
      end

      it 'requires deal type to exist' do
        data = build :deal_csv_data, type: 'N/A'
        expect(
          Deal.import(generate_csv(data), user)
        ).to eq([{row: 1, message: ["Deal Type #{data[:type]} could not be found"]}])
      end

      it 'requires deal source to exist' do
        data = build :deal_csv_data, source: 'N/A'
        expect(
          Deal.import(generate_csv(data), user)
        ).to eq([{row: 1, message: ["Deal Source #{data[:source]} could not be found"]}])
      end

      it 'requires start date to be valid' do
        data = build :deal_csv_data, start_date: 'zzz'
        expect(
          Deal.import(generate_csv(data), user)
        ).to eq([{row: 1, message: ['Start Date must have valid date format MM/DD/YYYY']}])
      end

      it 'requires end date to be valid' do
        data = build :deal_csv_data, end_date: 'zzz'
        expect(
          Deal.import(generate_csv(data), user)
        ).to eq([{row: 1, message: ['End Date must have valid date format MM/DD/YYYY']}])
      end

      it 'requires start date to be present if end date is set' do
        data = build :deal_csv_data, start_date: nil
        expect(
          Deal.import(generate_csv(data), user)
        ).to eq([{row: 1, message: ['Start Date must be present if End Date is set']}])
      end

      it 'requires end date to be present if start date is set' do
        data = build :deal_csv_data, end_date: nil
        expect(
          Deal.import(generate_csv(data), user)
        ).to eq([{row: 1, message: ['End Date must be present if Start Date is set']}])
      end

      it 'requires start date to preceed end date' do
        data = build :deal_csv_data, start_date: '12/12/2016', end_date: '11/11/2016'
        expect(
          Deal.import(generate_csv(data), user)
        ).to eq([{row: 1, message: ['Start Date must preceed End Date']}])
      end

      it 'requires stage to be present' do
        data = build :deal_csv_data
        data[:stage] = nil
        expect(
          Deal.import(generate_csv(data), user)
        ).to eq([{row: 1, message: ["Stage can't be blank"]}])
      end

      it 'requires stage to exist' do
        data = build :deal_csv_data, stage: 'N/A'
        expect(
          Deal.import(generate_csv(data), user)
        ).to eq([{row: 1, message: ["Stage #{data[:stage]} could not be found"]}])
      end

      it 'requires deal team to be present' do
        data = build :deal_csv_data
        data[:team] = nil
        expect(
          Deal.import(generate_csv(data), user)
        ).to eq([{row: 1, message: ["Team can't be blank"]}])
      end

      it 'requires deal team members to exist' do
        data = build :deal_csv_data, team: 'NA/0'
        expect(
          Deal.import(generate_csv(data), user)
        ).to eq([{row: 1, message: ["Deal Member #{data[:team].split('/')[0]} could not be found in the User list"]}])
      end

      it 'requires deal team member to have a share' do
        data = build :deal_csv_data, team: 'NA'
        expect(
          Deal.import(generate_csv(data), user)
        ).to eq([{row: 1, message: ["Deal Member #{data[:team].split('/')[0]} does not have a share"]}])
      end

      it 'requires created date to be a valid date' do
        data = build :deal_csv_data, created: 'NA'
        expect(
          Deal.import(generate_csv(data), user)
        ).to eq([{row: 1, message: ["Deal Creation Date must have valid date format MM/DD/YYYY"]}])
      end

      it 'requires closed date to be a valid date' do
        data = build :deal_csv_data, closed_date: 'NA'
        expect(
          Deal.import(generate_csv(data), user)
        ).to eq([{row: 1, message: ["Deal Close Date must have valid date format MM/DD/YYYY"]}])
      end

      it 'requires company close reason to exist' do
        data = build :deal_csv_data, close_reason: 'NA'
        expect(
          Deal.import(generate_csv(data), user)
        ).to eq([{row: 1, message: ["Close Reason #{data[:close_reason]} could not be found"]}])
      end

      it 'requires company contacts to exist' do
        data = build :deal_csv_data, contacts: 'NA'
        expect(
          Deal.import(generate_csv(data), user)
        ).to eq([{row: 1, message: ["Contact #{data[:contacts]} could not be found"]}])
      end
    end
  end

  context 'after_update' do
    let(:user) { create :user }
    let(:stage) { create :stage }
    let(:stage1) { create :stage }
    let(:deal) { create :deal, stage: stage, creator: user, updator: user, stage_updator: user, stage_updated_at: Date.new }
    it 'create deal_steage_log' do
      deal.update_attributes(stage: stage1)
      expect(DealStageLog.where(company_id: company.id, deal_id: deal.id, stage_id: stage.id, operation: 'U')).not_to be_nil
    end
  end

  context 'after_destroy' do
    let(:user) { create :user }
    let(:stage) { create :stage }
    let(:deal) { create :deal, stage: stage, creator: user, updator: user, stage_updator: user, stage_updated_at: Date.new }
    it 'create deal_steage_log' do
      deal.destroy
      expect(DealStageLog.where(company_id: company.id, deal_id: deal.id, stage_id: stage.id, operation: 'D')).not_to be_nil
    end
  end

  context 'before_create' do
    let(:won_stage) { create :stage, probability: 100, open: false }
    let(:lost_stage) { create :stage, probability: 0, open: false }
    let(:open_stage) { create :stage }

    it 'when create deal with closed won stage set closed_at date as created_at' do
      deal = build(
        :deal,
        stage: won_stage,
        creator: user,
        updator: user,
        stage_updator: user,
        stage_updated_at: Date.new,
        company: company
      )

      deal.save!

      expect(deal.closed_at).to eq deal.created_at.to_date
    end

    it 'when create deal with closed lost stage set closed_at date as created_at' do
      deal = build(
          :deal,
          stage: lost_stage,
          creator: user,
          updator: user,
          stage_updator: user,
          stage_updated_at: Date.new,
          company: company
      )

      deal.save!

      expect(deal.closed_at).to eq deal.created_at.to_date
    end

    it 'has not closed_at when create not open deal' do
      deal = build(
        :deal,
        stage: open_stage,
        creator: user,
        updator: user,
        stage_updator: user,
        stage_updated_at: Date.new,
        company: company
      )

      deal.save!

      expect(deal.closed_at).to be_nil
    end
  end

  private

  def user
    @_user ||= create :user
  end
end
