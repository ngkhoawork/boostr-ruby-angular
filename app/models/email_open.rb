class EmailOpen < ActiveRecord::Base
  belongs_to :email_thread, foreign_key: :guid, primary_key: :email_guid

  scope :by_thread, -> (guid) { where(guid: guid).order('opened_at') }

  validates :guid, :email,  presence: true
end
