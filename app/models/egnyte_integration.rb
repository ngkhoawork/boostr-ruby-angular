class EgnyteIntegration < ActiveRecord::Base
  belongs_to :company, required: true

  validates :company_id, uniqueness: true

  before_validation :escape_protocol_in_app_domain, if: 'app_domain.present? && app_domain_changed?'

  def self.find_by_state_token(state_token)
    find_by(access_token: state_token)
  end

  private

  def escape_protocol_in_app_domain
    self.app_domain = app_domain.sub(/https?:\/\//, '')
  end
end
