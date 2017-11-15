class FilterQuery < ActiveRecord::Base
  belongs_to :company
  belongs_to :user

  validates :user_id, :company_id, :name, :query_type, presence: true
  validates :name, uniqueness: { scope: [:company_id, :query_type],
                                 message: 'should be unique in scope of report.' }

  scope :by_user, -> (user_id) { where(user: user_id) }
  scope :by_user_and_global, -> (user_id) { where('user_id = ? OR global = true', user_id) }
  scope :by_query_type, -> (query_type) { where(query_type: query_type) if query_type.present? }
  scope :default, -> { where(default: true) }
  scope :all_without_specific_record, -> (filter_query_id) { where.not(id: filter_query_id) }
end
