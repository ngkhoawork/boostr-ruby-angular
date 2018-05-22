class HooplaConfiguration < ApiConfiguration
  has_one :hoopla_details, foreign_key: :api_configuration_id, inverse_of: :configuration, dependent: :destroy

  validate :connected_is_required_for_switched_on

  after_destroy :flush_hoopla_users

  after_commit :bind_deal_won_newsflash, on: [:create, :update]
  after_commit :bind_hoopla_users, on: [:create, :update]

  accepts_nested_attributes_for :hoopla_details

  def just_switched_on?
    switched_on? && previous_changes[:switched_on]
  end

  private

  def connected_is_required_for_switched_on
    errors.add(:switched_on, 'must be set after connected') if switched_on? && non_connected?
  end

  def bind_deal_won_newsflash
    return unless switched_on? && previous_changes[:switched_on] && deal_won_newsflash_href.blank?

    Hoopla::BindDealWonNewsflashWorker.perform_async(company_id)
  end

  def bind_hoopla_users
    Hoopla::BindCompanyUsersWorker.perform_async(company_id) if just_switched_on?
  end

  def flush_hoopla_users
    HooplaUser.where(user_id: company.user_ids).destroy_all
  end

  def method_missing(method, *args)
    if (hoopla_details || build_hoopla_details).respond_to?(method)
      hoopla_details.public_send(method, *args)
    else
      super
    end
  end
end
