require 'rails_helper'

RSpec.describe Api::ContractsController, type: :controller do
  let!(:contract) do
    create(
      :contract,
      company: company,
      advertiser: advertiser,
      agency: agency,
      deal: deal,
      holding_company: holding_company,
      type: type_option,
      status: status_option,
      contract_members_attributes: [{ user_id: user.id }],
      contract_contacts_attributes: [{ contact_id: contact.id }],
      special_terms_attributes: [{ comment: FFaker::Lorem.phrase }]
    )
  end

  let(:params) { {} }

  before { sign_in user }

  describe '#index' do

    subject { get :index, params }

    it 'returns a list of contracts' do
      subject

      expect(response).to be_success
      expect(response_body).to be_a_kind_of Array
      expect(first_json_object[:id]).to eq contract.id
    end

    context 'when user_id is provided' do
      let(:params) { { user_id: user_id } }

      context 'with matching value' do
        let(:user_id) { user.id }

        it { subject; expect(first_json_object[:id]).to eq contract.id }
      end

      context 'with non-matching value' do
        let(:user_id) { create(:user, company: company).id }

        it { subject; expect(response_body.count).to eq 0 }
      end
    end

    context 'when team_id is provided' do
      let(:params) { { team_id: team.id } }

      context 'with matching value' do
        context 'when user is a leader of team' do
          let(:team) { create(:team, company: company, leader: user) }

          it { subject; expect(first_json_object[:id]).to eq contract.id }
        end

        context 'when user is a member of team' do
          let(:team) do
            create(:team, company: company).tap { |team| team.members << user }
          end

          it { subject; expect(first_json_object[:id]).to eq contract.id }
        end

        context 'when user is a leader of sub team' do
          let(:team) { create(:team, company: company) }
          let!(:sub_team) { create(:team, company: company, leader: user, parent: team) }

          it { subject; expect(first_json_object[:id]).to eq contract.id }
        end

        context 'when user is a member of sub team' do
          let(:team) { create(:team, company: company) }
          let!(:sub_team) do
            create(:team, company: company, parent: team).tap { |team| team.members << user }
          end

          it { subject; expect(first_json_object[:id]).to eq contract.id }
        end
      end

      context 'with non-matching value' do
        let(:team) { create(:team, company: company) }

        it { subject; expect(response_body.count).to eq 0 }
      end
    end

    context 'when relation is provided' do
      let(:params) { { relation: relation } }

      context 'with value "my"' do
        let(:relation) { 'my' }

        context 'and match existing contracts' do
          it { subject; expect(first_json_object[:id]).to eq contract.id }
        end

        context 'and does not match existing contracts' do
          before { contract.contract_members.destroy_all }

          it { subject; expect(response_body.count).to eq 0 }
        end
      end

      context 'with value "my_teams"' do
        let(:relation) { 'my_teams' }

        context 'and user is binded to a team as a leader' do
          let!(:team) { create(:team, company: company, leader: user) }

          it { subject; expect(first_json_object[:id]).to eq contract.id }
        end

        context 'and user is binded to a team as a member' do
          let!(:team) do
            create(:team, company: company).tap { |team| team.members << user }
          end

          it { subject; expect(first_json_object[:id]).to eq contract.id }
        end

        context 'and user is not binded to any team' do
          it { subject; expect(response_body.count).to eq 0 }
        end
      end
    end

    context 'when advertiser_id is provided' do
      let(:params) { { advertiser_id: advertiser_id } }

      context 'with matching value' do
        let(:advertiser_id) { advertiser.id }

        it { subject; expect(first_json_object[:id]).to eq contract.id }
      end

      context 'with non-matching value' do
        let(:advertiser_id) { -1 }

        it { subject; expect(response_body.count).to eq 0 }
      end
    end

    context 'when advertiser_id is provided' do
      let(:params) { { agency_id: agency_id } }

      context 'with matching value' do
        let(:agency_id) { agency.id }

        it { subject; expect(first_json_object[:id]).to eq contract.id }
      end

      context 'with non-matching value' do
        let(:agency_id) { -1 }

        it { subject; expect(response_body.count).to eq 0 }
      end
    end

    context 'when deal_id is provided' do
      let(:params) { { deal_id: deal_id } }

      context 'with matching value' do
        let(:deal_id) { deal.id }

        it { subject; expect(first_json_object[:id]).to eq contract.id }
      end

      context 'with non-matching value' do
        let(:deal_id) { -1 }

        it { subject; expect(response_body.count).to eq 0 }
      end
    end

    context 'when holding_company_id is provided' do
      let(:params) { { holding_company_id: holding_company_id } }

      context 'with matching value' do
        let(:holding_company_id) { holding_company.id }

        it { subject; expect(first_json_object[:id]).to eq contract.id }
      end

      context 'with non-matching value' do
        let(:holding_company_id) { -1 }

        it { subject; expect(response_body.count).to eq 0 }
      end
    end

    context 'when type_id is provided' do
      let(:params) { { type_id: type_id } }

      context 'with matching value' do
        let(:type_id) { type_option.id }

        it { subject; expect(first_json_object[:id]).to eq contract.id }
      end

      context 'with non-matching value' do
        let(:type_id) { -1 }

        it { subject; expect(response_body.count).to eq 0 }
      end
    end

    context 'when status_id is provided' do
      let(:params) { { status_id: status_id } }

      context 'with matching value' do
        let(:status_id) { status_option.id }

        it { subject; expect(first_json_object[:id]).to eq contract.id }
      end

      context 'with non-matching value' do
        let(:status_id) { -1 }

        it { subject; expect(response_body.count).to eq 0 }
      end
    end

    context 'when start_date_start and start_date_end are provided' do
      let(:params) { { start_date_start: start_date_start, start_date_end: start_date_end } }

      context 'with matching value' do
        let(:start_date_start) { contract.start_date - 1.day }
        let(:start_date_end) { contract.start_date + 1.day }

        it { subject; expect(first_json_object[:id]).to eq contract.id }
      end

      context 'with non-matching value' do
        let(:start_date_start) { contract.start_date - 1.day }
        let(:start_date_end) { contract.start_date - 1.day }

        it { subject; expect(response_body.count).to eq 0 }
      end
    end

    context 'when end_date_start and end_date_end are provided' do
      let(:params) { { end_date_start: end_date_start, end_date_end: end_date_end } }

      context 'with matching value' do
        let(:end_date_start) { contract.end_date - 1.day }
        let(:end_date_end) { contract.end_date + 1.day }

        it { subject; expect(first_json_object[:id]).to eq contract.id }
      end

      context 'with non-matching value' do
        let(:end_date_start) { contract.end_date - 1.day }
        let(:end_date_end) { contract.end_date - 1.day }

        it { subject; expect(response_body.count).to eq 0 }
      end
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
    let(:attributes) do
      attributes_for(
        :contract,
        type_id: type_option.id,
        status_id: status_option.id,
        holding_company_id: holding_company.id
      )
    end
    let(:params) { { contract: attributes } }

    subject { post :create, params }

    it 'creates a contract' do
      expect{subject}.to change{Contract.count}.by(1)
      expect(last_created_contract.type_id).to eq type_option.id
      expect(last_created_contract.status_id).to eq status_option.id
      expect(last_created_contract.holding_company_id).to eq holding_company.id
      expect(response).to have_http_status(201)
      expect(response_body[:id]).to eq Contract.last.id
    end

    context 'when valid assocs params are included' do
      let(:attributes) do
        super().merge!(
          contract_members_attributes: [{ user_id: user.id }],
          contract_contacts_attributes: [{ contact_id: contact.id }],
          special_terms_attributes: [{ comment: FFaker::Lorem.phrase }]
        )
      end

      it do
        expect{subject}.to change{Contract.count}.by(1).and \
                           change{ContractMember.count}.by(1).and \
                           change{ContractContact.count}.by(1).and \
                           change{SpecialTerm.count}.by(1)
      end
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

    context 'when valid type, status params are included' do
      let(:attributes) { super().merge!(type_id: another_type_option.id, status_id: another_status_option.id) }

      it do
        expect{subject}.to change{contract.reload.type_id}.to(another_type_option.id).and \
                           change{contract.reload.status_id}.to(another_status_option.id)
      end
    end

    context 'when _destroy option is present for member, contact, special term' do
      let(:attributes) do
        super().merge!(
          contract_members_attributes: [{ id: contract_members[0].id, _destroy: true }],
          contract_contacts_attributes: [{ id: contract_contacts[0].id, _destroy: true }],
          special_terms_attributes: [{ id: special_terms[0].id, _destroy: true }]
        )
      end

      it do
        expect{subject}.to change{contract.reload.name}.to(params[:contract][:name]).and \
                           change{ContractMember.count}.by(-1).and \
                           change{ContractContact.count}.by(-1).and \
                           change{SpecialTerm.count}.by(-1)
      end
    end
  end

  describe '#destroy' do
    let(:params) { { id: contract.id } }
    subject { delete :destroy, params }

    it { expect{ subject }.to change{Contract.count}.by(-1) }
  end

  describe '#settings' do
    subject { get :settings }

    it do
      subject

      expect(response).to be_success
      expect(response_body.keys).to match_array(
        [
          :type_options,
          :status_options,
          :member_role_options,
          :contact_role_options,
          :special_term_name_options,
          :special_term_type_options,
          :linked_deals,
          :linked_advertisers,
          :linked_agencies,
          :linked_holding_companies,
          :linked_users
        ]
      )
    end
  end

  private

  def response_body
    @_response_body ||= JSON.parse(response.body, symbolize_names: true)
  end

  def first_json_object
    @_first_json_object ||= response_body.first
  end

  def company
    @_company ||= create(:company)
  end

  def advertiser
    @_advertiser ||= create(:client, :advertiser, company: company)
  end

  def agency
    @_agency ||= create(:client, :agency, company: company)
  end

  def deal
    @_deal ||= create(:deal, company: company)
  end

  def holding_company
    @_holding_company ||= create(:holding_company)
  end

  def user
    @_user ||= create(:user, company: company, is_legal: true)
  end

  def last_created_contract
    @_last_created_contract ||= Contract.last
  end

  def contact
    @_contact ||= create(:contact, company: company)
  end

  def contract_members
    @_contract_member ||= contract.contract_members
  end

  def contract_contacts
    @_contract_contacts ||= contract.contract_contacts
  end

  def special_terms
    @_special_terms ||= contract.special_terms
  end

  def type_field
    @_type_field ||= create(:field, subject_type: 'Contract', name: 'Type', company: company)
  end

  def type_option
    @_type_option ||= create(:option, company: company, name: 'Contract Type 1', field: type_field)
  end

  def another_type_option
    @_another_type_option ||= create(:option, company: company, name: 'Contract Type 2', field: type_field)
  end

  def status_field
    @_status_field ||= create(:field, subject_type: 'Contract', name: 'Status', company: company)
  end

  def status_option
    @_status_option ||= create(:option, company: company, name: 'Contract Status 1', field: status_field)
  end

  def another_status_option
    @_another_status_option ||= create(:option, company: company, name: 'Contract Status 2', field: status_field)
  end
end
