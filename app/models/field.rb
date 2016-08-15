class Field < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :company

  has_many :options
  has_many :values

  default_scope { order(:name) }

  VALUE_TYPES = ['Text', 'Number', 'Decimal', 'Percent', 'Money', 'Datetime', 'Option', 'Object']

  validates :name, presence: true
  validates :company, presence: true
  validates :subject_type, presence: true # The type of object this field applies to Deal, Client, Team
  validates :value_type, inclusion: VALUE_TYPES, presence: true

  def as_json(opts = {})
    super(opts.merge(include: [options: {include: [:suboptions]}]))
  end
end
