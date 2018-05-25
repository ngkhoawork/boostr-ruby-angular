require 'rails_helper'

describe Leads::UserAssignmentService do
  
  describe '#perform' do
    context 'user assignment' do
      context 'rule with country field type' do
        let(:lead) { create :lead, company: company, country: 'USA', state: 'NY' }

        before do
          assignment_rule.update(field_type: AssignmentRule::COUNTRY, criteria_1: ['USA'], criteria_2: ['NY'])

          create :assignment_rules_user, user: user, assignment_rule: assignment_rule, next: true
        end

        it 'assign user from rule for lead' do
          expect(lead.user_id).to eq user.id
        end
      end

      context 'rule with source field type' do
        let(:lead) { create :lead, company: company, source_url: 'advertise_form' }

        before do
          assignment_rule.update(field_type: AssignmentRule::SOURCE_URL, criteria_1: ['advertise_form'])

          create :assignment_rules_user, user: user, assignment_rule: assignment_rule, next: true
        end

        it 'assign user from rule for lead' do
          expect(lead.user_id).to eq user.id
        end
      end

      context 'rule with product field type' do
        let(:lead) { create :lead, company: company, product_name: 'Display' }

        before do
          assignment_rule.update(field_type: AssignmentRule::PRODUCT_NAME, criteria_1: ['Display'])

          create :assignment_rules_user, user: user, assignment_rule: assignment_rule, next: true
        end

        it 'assign user from rule for lead' do
          expect(lead.user_id).to eq user.id
        end
      end

      context 'default rule' do
        let(:lead) { create :lead, company: company }

        before do
          assignment_rule.update(default: true)

          create :assignment_rules_user, user: user, assignment_rule: assignment_rule, next: true
        end

        it 'assign user from rule for lead' do
          expect(lead.user_id).to eq user.id
        end
      end
    end

    context 'rule updating' do
      context 'when first rule in list is next' do
        let(:second_user) { create :user, company: company }
        let(:first_assignment_rules_user) { create :assignment_rules_user,
                                                    user: user,
                                                    assignment_rule: assignment_rule }
        let(:second_assignment_rules_user) { create :assignment_rules_user,
                                                     user: second_user,
                                                     assignment_rule: assignment_rule }
  
        it 'update rule next attribute' do
          second_assignment_rules_user.update(next: false)
          assignment_rule.update(default: true)
  
          expect(first_assignment_rules_user.next).to eq true
          expect(second_assignment_rules_user.next).to eq false
  
          create :lead, company: company
  
          expect(first_assignment_rules_user.reload.next).to be false
          expect(second_assignment_rules_user.reload.next).to be true
        end
      end
    end

    context 'when last rule in list is next' do
      let(:second_user) { create :user, company: company }
      let(:first_assignment_rules_user) { create :assignment_rules_user,
                                                 user: user,
                                                 assignment_rule: assignment_rule }
      let(:second_assignment_rules_user) { create :assignment_rules_user,
                                                  user: second_user,
                                                  assignment_rule: assignment_rule }

      it 'update rule next attribute' do
        first_assignment_rules_user.update(next: false)
        assignment_rule.update(default: true)

        expect(first_assignment_rules_user.next).to eq false
        expect(second_assignment_rules_user.next).to eq true

        create :lead, company: company

        expect(first_assignment_rules_user.reload.next).to be true
        expect(second_assignment_rules_user.reload.next).to be false
      end
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
    @_assignment_rule ||= create :assignment_rule,
                                 name: 'Test',
                                 default: false,
                                 company: company
  end
end
