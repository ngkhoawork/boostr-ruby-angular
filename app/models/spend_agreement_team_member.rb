class SpendAgreementTeamMember < ActiveRecord::Base
  belongs_to :spend_agreement
  belongs_to :user

  has_many :values, as: :subject

  validates_uniqueness_of :user_id, scope: [:spend_agreement_id]

  scope :exclude_ids, -> ids { where.not(id: ids) if ids.present? }

  accepts_nested_attributes_for :values, {
    reject_if: proc { |attributes| attributes['option_id'].blank? }
  }

  def value_from_field(field_id)
    values.find{ |val| val.field_id == field_id }&.option&.name
  end
end
