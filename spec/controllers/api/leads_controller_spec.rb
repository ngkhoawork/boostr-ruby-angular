require 'rails_helper'

describe Api::LeadsController do
  before { sign_in user }

  describe 'GET #index' do
    context 'my' do
      context 'new leads' do
        it 'return leads related to current user' do
          create_list :lead, 5, company: company, user: user

          get :index, relation: 'my', status: 'new_leads'

          expect(json_response.length).to eq 5
        end

        it 'do not return leads if current user do not have them' do
          create_list :lead, 5, company: company, user: second_user

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
          create_list :lead, 5, company: company, user: user
          create_list :lead, 5, company: company, user: second_user

          get :index, relation: 'team', status: 'new_leads'

          expect(json_response.length).to eq 10
        end

        it 'do not return leads if team of current user do not have them' do
          create_list :lead, 5, company: company, user: create(:user)

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
          create_list :lead, 5, company: company, user: user

          get :index, relation: 'all', status: 'new_leads'

          expect(json_response.length).to eq 5
        end

        it 'do not return leads if company of current user do not have them' do
          create_list :lead, 5, company: second_company, user: create(:user, company: second_company)

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
      expect(lead.user_id).to be_nil

      get :reassign, id: lead.id, user_id: user.id

      expect(lead.reload.user_id).to eq user.id
    end
  end

  describe 'GET #reopen' do
    it 'reopen lead successfully' do
      lead.update(user: user, status: Lead::REJECTED)

      expect(lead.user_id).not_to be_nil
      expect(lead.status).not_to be_nil
      expect(lead.reopened_at).to be_nil

      get :reopen, id: lead.id

      expect(lead.reload.user_id).to be_nil
      expect(lead.reload.status).to be_nil
      expect(lead.reload.reopened_at).not_to be_nil
    end
  end

  private

  def company
    @_company ||= create :company
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
    @_lead ||= create :lead, company: company
  end
end
