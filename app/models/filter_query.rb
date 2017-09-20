class FilterQuery < ActiveRecord::Base
  belongs_to :company
  belongs_to :user

  validates :user_id, :company_id, :name, :query_type, presence: true

  scope :by_user_and_global, -> (user_id) { where('user_id = ? OR global = true', user_id) }
  scope :by_query_type, -> (query_type) { where(query_type: query_type) if query_type.present? }
end
