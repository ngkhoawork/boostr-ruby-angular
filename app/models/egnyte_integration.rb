class EgnyteIntegration < ActiveRecord::Base
  belongs_to :company, required: true

  validates :company_id, uniqueness: true
  validate :app_domain_is_required_for_enabled

  before_validation :escape_protocol_in_app_domain, if: 'app_domain.present? && app_domain_changed?'

  def self.find_by_state_token(state_token)
    find_by(access_token: state_token)
  end

  def enabled_and_connected?
    enabled? && connected?
  end

  private

  def app_domain_is_required_for_enabled
    errors.add(:enabled, 'can not be set without app_domain') if enabled? && app_domain.blank?
  end

  def escape_protocol_in_app_domain
    self.app_domain = app_domain.sub(/https?:\/\//, '')
  end
end
