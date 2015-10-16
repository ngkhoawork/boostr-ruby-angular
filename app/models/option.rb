class Option < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :company
  belongs_to :field

  has_many :values

  validates :name, :company, :field, presence: true
  validate :unique_name

  before_create :set_position

  def used
    values.count > 0
  end

  def as_json(options = {})
    super(options.merge(methods: [:used]))
  end

  protected

  # Because we have soft-deletes uniqueness validations must be custom
  def unique_name
    return true unless company && name
    scope = field.options.where('LOWER(name) = ?', self.name.downcase)
    scope = scope.where('id <> ?', self.id) if self.id

    errors.add(:name, 'Name has already been taken') if scope.count > 0
  end

  def set_position
    self.position ||= Option.count
  end
end
