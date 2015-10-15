class ClientType < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :company
  has_many :clients

  validates :company, :name, presence: true
  validate :unique_name

  before_create :set_position

  # 3) Must have advertiser and agency

  # 5) Reorders the positions if you change the position
  # function update_position_values(array) {
  #   $.each(array, function(index, el){
  #     id = el.replace("post_", "");

  #     $.ajax({
  #       url: '/posts/' + id,
  #       type: 'PUT',
  #       data: { post: { position: index } }
  #     })
  #   })
  # }

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
