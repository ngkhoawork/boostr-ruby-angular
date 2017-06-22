class Influencer < ActiveRecord::Base
  belongs_to :company
  has_one :agreement, dependent: :destroy
  has_many :values, as: :subject
  has_many :influencer_content_fees

  accepts_nested_attributes_for :agreement
  accepts_nested_attributes_for :values

  scope :by_name, -> name { where('influencers.name ilike ?', "%#{name}%") if name.present? }

  def fields
    company.fields.where(subject_type: self.class.name)
  end

  def network_name
    subject_fields = fields
    if !subject_fields.nil?
      field = subject_fields.find_by_name('Network')
      value = values.find_by_field_id(field.id) if !field.nil?
      option = value.option.name if !value.nil? && !value.option.nil?
    end
    option
  end
end
