require 'rails_helper'

RSpec.describe Contracts::SerializersPolicy do
  describe '#serialize_collection' do
    subject { described_class.serialize_collection(user, collection) }

    context 'when user is legal' do
      let(:is_legal) { true }

      it 'shows all index columns' do
        expect(
          subject.find { |contract| contract[:id] == restricted_contract.id }.keys
        ).to match_array all_index_columns
      end

      it 'shows all index columns' do
        expect(
          subject.find { |contract| contract[:id] == not_restricted_contract.id }.keys
        ).to match_array all_index_columns
      end
    end

    context 'when user is not legal' do
      let(:is_legal) { false }

      it 'shows only basic index columns' do
        expect(
          subject.find { |contract| contract[:id] == restricted_contract.id }.keys
        ).to match_array restricted_index_columns
      end

      it 'shows all index columns' do
        expect(
          subject.find { |contract| contract[:id] == not_restricted_contract.id }.keys
        ).to match_array all_index_columns
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

  def collection
    @_collection ||= Contract.where(id: [restricted_contract.id, not_restricted_contract.id])
  end

  def restricted_contract
    @_restricted_contract ||= create(:contract, company: company, type: type_option, restricted: true)
  end

  def not_restricted_contract
    @_not_restricted_contract ||= create(:contract, company: company, type: type_option, restricted: false)
  end

  def type_field
    @_type_field ||= create(:field, company: company, subject_type: 'Contract', name: 'Type')
  end

  def type_option
    @_type_option ||= create(:option, company: company, name: 'Contract Type 1', field: type_field)
  end

  def all_index_columns
    [:id, :company_id, :days_notice_required, :name, :restricted, :type, :status, :advertiser, :agency, :deal]
  end

  def restricted_index_columns
    [:id, :company_id, :name, :restricted, :type]
  end
end
