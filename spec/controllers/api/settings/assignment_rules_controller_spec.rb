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
    it 'update countries list' do
      expect(assignment_rule.countries).to be_empty

      put :update, id: assignment_rule.id, assignment_rule: { countries: ['USA'] }

      expect(assignment_rule.reload.countries).to include 'USA'
    end

    it 'update states list' do
      expect(assignment_rule.countries).to be_empty

      put :update, id: assignment_rule.id, assignment_rule: { states: ['Arizona', 'California'] }

      expect(assignment_rule.reload.states).to include 'Arizona'
      expect(assignment_rule.reload.states).to include 'California'
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
