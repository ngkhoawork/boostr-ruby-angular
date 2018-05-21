require 'rails_helper'

describe Api::Settings::AssignmentRulesController do
  before { sign_in user }

  describe 'GET #index' do
    it 'return proper count of assignment rules' do
      create_list :assignment_rule, 5, company: company

      get :index

      expect(json_response.length).to eq 5
    end
  end

  describe 'POST #create' do
    it 'creates assignment rule successfully' do
      expect {
        post :create, assignment_rule: { name: 'Test Rule' }
      }.to change(AssignmentRule, :count).by(1)
    end

    it 'failed to create assignment rule' do
      expect {
        post :create, assignment_rule: { name: '' }
      }.not_to change(AssignmentRule, :count)
    end
  end

  describe 'PUT #update' do
    it 'update criteria_1 list' do
      expect(assignment_rule.criteria_1).to be_empty

      put :update, id: assignment_rule.id, assignment_rule: { criteria_1: ['USA'] }

      expect(assignment_rule.reload.criteria_1).to include 'USA'
    end

    it 'update criteria_2 list' do
      expect(assignment_rule.criteria_1).to be_empty

      put :update, id: assignment_rule.id, assignment_rule: { criteria_2: ['Arizona', 'California'] }

      expect(assignment_rule.reload.criteria_2).to include 'Arizona'
      expect(assignment_rule.reload.criteria_2).to include 'California'
    end
  end

  describe 'DELETE #destroy' do
    it 'delete assignment rule successfully' do
      assignment_rule = create :assignment_rule, company: company

      expect{
        delete :destroy, id: assignment_rule.id
      }.to change{AssignmentRule.count}.by(-1)
    end
  end

  describe 'GET #add_user' do
    it 'add user to assignment rules' do
      expect(assignment_rule.users).to be_empty

      get :add_user, id: assignment_rule.id, user_id: user.id

      expect(assignment_rule.reload.users).to include user
    end
  end

  describe 'GET #remove_user' do
    it 'remove user from assignment rules' do
      assignment_rule.users << user

      expect(assignment_rule.users).to include user

      get :remove_user, id: assignment_rule.id, user_id: user.id

      expect(assignment_rule.reload.users).to be_empty
    end
  end

  describe 'PUT #update_positions' do
    it 'update assignment rules positions successfully' do
      assignment_rules = create_list :assignment_rule, 2, company: company
      assignment_rules_ids = assignment_rules.map(&:id)
      position_params =  Hash[assignment_rules_ids.map { |i| [i.to_s, i+1] }]

      put :update_positions, positions: position_params

      assignment_rules.map(&:reload)

      expect(assignment_rules.first.position).to eq(position_params[assignment_rules.first.id.to_s])
      expect(assignment_rules.last.position).to eq(position_params[assignment_rules.last.id.to_s])
    end
  end


  private

  def company
    @_company ||= create :company
  end

  def user
    @_user ||= create :user, company: company
  end

  def assignment_rule
    @_assignment_rule ||= create :assignment_rule, company: company
  end
end
