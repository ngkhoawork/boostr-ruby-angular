require 'rails_helper'

RSpec.describe Contracts::ActionsPolicy do
  describe '#authorize!' do
    subject { described_class.new(user, contract).authorize!(action) }

    context 'when user is legal' do
      let(:is_legal) { true }
      let(:restricted) { true }

      context 'for "index"' do
        let(:action) { :index }

        it { expect(subject).to eq true }
      end

      context 'for "create"' do
        let(:action) { :create }

        it { expect(subject).to eq true }
      end

      context 'for "update"' do
        let(:action) { :update }

        it { expect(subject).to eq true }
      end

      context 'for "show"' do
        let(:action) { :show }

        it { expect(subject).to eq true }
      end

      context 'for "destroy"' do
        let(:action) { :destroy }

        it { expect(subject).to eq true }
      end
    end

    context 'when user is not legal' do
      let(:is_legal) { false }

      context 'and contract is not restricted' do
        let(:restricted) { false }

        context 'for "index"' do
          let(:action) { :index }

          it { expect(subject).to eq true }
        end

        context 'for "create"' do
          let(:action) { :create }

          it { expect(subject).to eq true }
        end

        context 'for "update"' do
          let(:action) { :update }

          it { expect(subject).to eq true }
        end

        context 'for "show"' do
          let(:action) { :show }

          it { expect(subject).to eq true }
        end

        context 'for "destroy"' do
          let(:action) { :destroy }

          it { expect{subject}.to raise_error(ApplicationPolicy::NotAuthorizedError) }
        end
      end

      context 'and contract is restricted' do
        let(:restricted) { true }

        context 'for "index"' do
          let(:action) { :index }

          it { expect(subject).to eq true }
        end

        context 'for "create"' do
          let(:action) { :create }

          it { expect(subject).to eq true }
        end

        context 'for "update"' do
          let(:action) { :update }

          it { expect{subject}.to raise_error(ApplicationPolicy::NotAuthorizedError) }
        end

        context 'for "show"' do
          let(:action) { :show }

          it { expect{subject}.to raise_error(ApplicationPolicy::NotAuthorizedError) }
        end

        context 'for "destroy"' do
          let(:action) { :destroy }

          it { expect{subject}.to raise_error(ApplicationPolicy::NotAuthorizedError) }
        end
      end
    end
  end

  private

  def company
    @_company ||= create(:company)
  end

  def user
    @_user ||= create(:user, company: company, is_legal: is_legal)
  end

  def contract
    @_contract ||= create(:contract, company: company, type: type_option, restricted: restricted)
  end

  def type_field
    @_type_field ||= company.fields.find_by!(subject_type: 'Contract', name: 'Type')
  end

  def type_option
    @_type_option ||= create(:option, company: company, name: 'Contract Type 1', field: type_field)
  end
end
