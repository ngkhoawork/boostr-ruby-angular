class EgnyteIntegration < ActiveRecord::Base
  attr_accessor :connect_email

  belongs_to :company, required: true

  validates :company_id, uniqueness: true
  validate :connected_is_required_for_enabled

  before_validation :escape_protocol_in_app_domain, if: 'app_domain.present? && app_domain_changed?'
  before_save :ensure_defaults

  class << self
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

  def connected?
    !!access_token
  end

  def non_connected?
    !connected?
  end

  private

  delegate :deal_folder_tree_default, :deals_folder_name_default, to: :class

  def account_folder_tree_default
    self.class.account_folder_tree_default.tap do |account_folder_tree|
      title = deals_folder_name || deals_folder_name_default

      account_folder_tree[:nodes] << {
        title: title,
        nodes: []
      } unless account_folder_tree[:nodes].map { |node| node[:title] }.include?(title)
    end
  end

  def connected_is_required_for_enabled
    errors.add(:base, 'can not be enabled before connected') if enabled? && non_connected?
  end

  def escape_protocol_in_app_domain
    self.app_domain = app_domain.sub(/https?:\/\//, '')
  end

  def ensure_defaults
    self.deals_folder_name = deals_folder_name_default if deals_folder_name.blank?
    self.account_folder_tree = account_folder_tree_default if account_folder_tree.blank?
    self.deal_folder_tree = deal_folder_tree_default if deal_folder_tree.blank?
  end
end
