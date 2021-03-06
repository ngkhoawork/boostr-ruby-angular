require 'rails_helper'

describe Api::LeadsController do
  before { sign_in user }

  describe 'GET #index' do
    context 'my' do
      context 'new leads' do
        it 'return leads related to current user' do
          create_list :lead, 5, company: company, user: user, status: Lead::NEW

          get :index, relation: 'my', status: 'new_leads'

          expect(json_response.length).to eq 5
        end

        it 'do not return leads if current user do not have them' do
          create_list :lead, 5, company: company, user: second_user, status: Lead::NEW

          get :index, relation: 'my', status: 'new_leads'

          expect(json_response.length).to eq 0
        end
      end

      context 'accepted' do
        it 'return leads related to current user' do
          create_list :lead, 3, company: company, user: user, status: Lead::ACCEPTED

          get :index, relation: 'my', status: 'accepted'

          expect(json_response.length).to eq 3
        end

        it 'do not return leads if current user do not have them' do
          create_list :lead, 3, company: company, user: second_user, status: Lead::ACCEPTED

          get :index, relation: 'my', status: 'accepted'

          expect(json_response.length).to eq 0
        end
      end

      context 'rejected' do
        it 'return leads related to current user' do
          create_list :lead, 4, company: company, user: user, status: Lead::REJECTED

          get :index, relation: 'my', status: 'rejected'

          expect(json_response.length).to eq 4
        end

        it 'do not return leads if current user do not have them' do
          create_list :lead, 4, company: company, user: second_user, status: Lead::REJECTED

          get :index, relation: 'my', status: 'rejected'

          expect(json_response.length).to eq 0
        end
      end
    end

    context 'team' do
      let!(:team) { create :team, company: company, leader: user, members: [second_user] }

      context 'new leads' do
        it 'return leads related to team of current user' do
          create_list :lead, 5, company: company, user: user, status: Lead::NEW
          create_list :lead, 5, company: company, user: second_user, status: Lead::NEW

          get :index, relation: 'team', status: 'new_leads'

          expect(json_response.length).to eq 10
        end

        it 'do not return leads if team of current user do not have them' do
          create_list :lead, 5, company: company, user: create(:user), status: Lead::NEW

          get :index, relation: 'team', status: 'new_leads'

          expect(json_response.length).to eq 0
        end
      end

      context 'accepted' do
        it 'return leads related to team of current user' do
          create_list :lead, 3, company: company, user: user, status: Lead::ACCEPTED
          create_list :lead, 3, company: company, user: second_user, status: Lead::ACCEPTED

          get :index, relation: 'team', status: 'accepted'

          expect(json_response.length).to eq 6
        end

        it 'do not return leads if team of current user do not have them' do
          create_list :lead, 3, company: company, user: create(:user), status: Lead::ACCEPTED

          get :index, relation: 'team', status: 'accepted'

          expect(json_response.length).to eq 0
        end
      end

      context 'rejected' do
        it 'return leads related to team of current user' do
          create_list :lead, 4, company: company, user: user, status: Lead::REJECTED
          create_list :lead, 4, company: company, user: second_user, status: Lead::REJECTED

          get :index, relation: 'team', status: 'rejected'

          expect(json_response.length).to eq 8
        end

        it 'do not return leads if team of current user do not have them' do
          create_list :lead, 3, company: company, user: create(:user), status: Lead::REJECTED

          get :index, relation: 'team', status: 'rejected'

          expect(json_response.length).to eq 0
        end
      end
    end

    context 'all' do
      context 'new leads' do
        it 'return leads related to company of current user' do
          create_list :lead, 5, company: company, user: user, status: Lead::NEW

          get :index, relation: 'all', status: 'new_leads'

          expect(json_response.length).to eq 5
        end

        it 'do not return leads if company of current user do not have them' do
          create_list :lead, 5, company: second_company, user: create(:user, company: second_company), status: Lead::NEW

          get :index, relation: 'all', status: 'new_leads'

          expect(json_response.length).to eq 0
        end
      end

      context 'accepted' do
        it 'return leads related to company of current user' do
          create_list :lead, 3, company: company, user: user, status: Lead::ACCEPTED

          get :index, relation: 'all', status: 'accepted'

          expect(json_response.length).to eq 3
        end

        it 'do not return leads if company of current user do not have them' do
          create_list :lead, 3, company: second_company, user: create(:user, company: second_company),
                      status: Lead::ACCEPTED

          get :index, relation: 'all', status: 'accepted'

          expect(json_response.length).to eq 0
        end
      end

      context 'rejected' do
        it 'return leads related to company of current user' do
          create_list :lead, 4, company: company, user: user, status: Lead::REJECTED

          get :index, relation: 'all', status: 'rejected'

          expect(json_response.length).to eq 4
        end

        it 'do not return leads if company of current user do not have them' do
          create_list :lead, 3, company: second_company, user: create(:user, company: second_company),
                      status: Lead::REJECTED

          get :index, relation: 'all', status: 'rejected'

          expect(json_response.length).to eq 0
        end
      end
    end
  end

  describe 'GET #accept' do
    it 'accept lead successfully' do
      expect(lead.status).to be_nil
      expect(lead.accepted_at).to be_nil

      get :accept, id: lead.id

      expect(lead.reload.status).to eq Lead::ACCEPTED
      expect(lead.reload.accepted_at).not_to be_nil
    end
  end

  describe 'GET #reject' do
    it 'reject lead successfully' do
      expect(lead.status).to be_nil
      expect(lead.rejected_at).to be_nil

      get :reject, id: lead.id

      expect(lead.reload.status).to eq Lead::REJECTED
      expect(lead.reload.rejected_at).not_to be_nil
    end
  end
  
  describe 'GET #reassign' do
    it 'reassign lead successfully' do
      get :reassign, id: lead.id, user_id: user.id

      expect(lead.reload.user_id).to eq user.id
    end
  end

  describe 'PUT #update' do
    it 'update lead successfully' do
      expect(lead.rejected_reason).to be_nil

      put :update, id: lead.id, lead: { rejected_reason: 'Does not fit our criteria' }

      expect(lead.reload.rejected_reason).to eq 'Does not fit our criteria'
    end
  end

  private

  def company
    @_company ||= create :company, users: [create(:user)]
  end

  def second_company
    @_second_company ||= create :company
  end

  def user
    @_user ||= create :user, company: company
  end

  def second_user
    @_second_user ||= create :user, company: company
  end

  def lead
    @_lead ||= create :lead, company: company, user: user
  end

  def valid_lead_params
    attributes_for(:lead).merge(company_id: company.id)
  end

  def assignment_rule
    @_assignment_rule ||= create :assignment_rule, company_id: company.id, criteria_1: ['Usa'], criteria_2: ['Ny']
  end
end
