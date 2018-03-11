class Option < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :company
  belongs_to :field
  belongs_to :option, class_name: "Option"
  has_many   :suboptions,
             class_name: "Option",
             dependent: :destroy

  has_many :values

  validates :name, :company, presence: true
  validates :field, presence: true, unless: ->(option){option.option.present?}
  validates :option, presence: true, unless: ->(option){option.field.present?}

  validate :unique_name

  scope :by_name, -> name { where('name ilike ?', name) }
  scope :for_company, -> (id) { where(company_id: id) }

  before_create :set_position

  def used
    values.count > 0
  end

  def as_json(options = {})
    super(options.merge(include: :suboptions, methods: [:used]))
  end

  protected

  # Because we have soft-deletes uniqueness validations must be custom
  def unique_name
    return true unless company && name
    scope = neighbour_options.where('LOWER(name) = ?', self.name.downcase)
    scope = scope.where('id <> ?', self.id) if self.id

    errors.add(:name, "Option name #{name} has already been taken") if scope.count > 0
  end

  def neighbour_options
    if field
      field.options
    elsif option
      option.suboptions
    end
  end

  def set_position
    self.position ||= Option.count
  end
end
