class EgnyteIntegration < ActiveRecord::Base
  belongs_to :company

  validates :company_id, uniqueness: true
  validate :app_domain_is_required_for_enabled

  before_validation :escape_protocol_in_app_domain, if: 'app_domain.present? && app_domain_changed?'
  before_save :ensure_defaults

  class << self
    def find_by_state_token(state_token)
      find_by(access_token: state_token)
    end

    def deal_folder_tree_default
      {
        title: 'Deal',
        nodes: [
          {
            title: 'RFP',
            nodes: []
          },
          {
            title: 'Proposals',
            nodes: []
          }
        ]
      }
    end

    def account_folder_tree_default
      {
        title: 'Account',
        nodes: [
          {
            title: 'Contracts',
            nodes: []
          },
          {
            title: 'Templates',
            nodes: []
          },
          {
            title: 'Accounts',
            nodes: []
          }
        ]
      }
    end

    def deals_folder_name_default
      'Deals'
    end
  end

  def enabled_and_connected?
    enabled? && connected?
  end

  private

  delegate :deal_folder_tree_default, :account_folder_tree_default, :deals_folder_name_default, to: :class

  def app_domain_is_required_for_enabled
    errors.add(:enabled, 'can not be set without app_domain') if enabled? && app_domain.blank?
  end

  def escape_protocol_in_app_domain
    self.app_domain = app_domain.sub(/https?:\/\//, '')
  end

  def ensure_defaults
    self.account_folder_tree = account_folder_tree_default if account_folder_tree.blank?
    self.deal_folder_tree = deal_folder_tree_default if deal_folder_tree.blank?
    self.deals_folder_name = deals_folder_name_default if deals_folder_name.blank?
  end
end
