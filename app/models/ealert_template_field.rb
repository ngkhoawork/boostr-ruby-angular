class EalertTemplateField < ActiveRecord::Base
  belongs_to :ealert_template, class_name: 'EalertTemplate::Base', required: true

  validates :name, presence: true

  scope :with_position, -> { where.not(position: nil) }

  def label
    name&.humanize
  end
end
