class Field < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :company

  has_many :options, dependent: :destroy
  has_many :values, dependent: :destroy

  default_scope { order(:name) }

  scope :client_category_fields, -> { where(subject_type: 'Client', name: 'Category') }
  scope :for_client, -> (client_id) { where('advertiser_id = ? OR agency_id = ?', client_id, client_id) if client_id.present? }
  scope :client_region_fields, -> { where(subject_type: 'Client', name: 'Region') }
  scope :client_segment_fields, -> { where(subject_type: 'Client', name: 'Segment') }


  VALUE_TYPES = ['Text', 'Number', 'Decimal', 'Percent', 'Money', 'Datetime', 'Option', 'Object']

  validates :name, presence: true
  validates :company, presence: true
  validates :subject_type, presence: true # The type of object this field applies to Deal, Client, Team
  validates :value_type, inclusion: VALUE_TYPES, presence: true

  def as_json(opts = {})
    super(opts.merge(include: [options: {include: [:suboptions]}]))
  end

  def option_from_name(name)
    self.options.find do |opt|
      opt.name.casecmp(name) == 0
    end
  end

  def option_locked
    self.options.find do |opt|
      opt.locked == true
    end
  end

  def self.to_options
    joins(:options).pluck_to_struct('options.id as id', 'options.name as name')
  end
end
