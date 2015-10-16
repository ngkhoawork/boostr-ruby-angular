class ClientType < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :company
  has_many :clients

  default_scope { order(:position) }

  validates :company, :name, presence: true
  validate :unique_name

  before_create :set_position

  def locked
    name == 'Agency' || name == 'Advertiser'
  end

  def used
    clients.count > 0
  end

  def as_json(options = {})
    super(options.merge(methods: [:locked, :used]))
  end

  protected

  # Because we have soft-deletes uniqueness validations must be custom
  def unique_name
    return true unless company && name
    scope = company.client_types.where('LOWER(name) = ?', self.name.downcase)
    scope = scope.where('id <> ?', self.id) if self.id

    errors.add(:name, 'Name has already been taken') if scope.count > 0
  end

  def set_position
    self.position ||= company.client_types.count
  end
end
