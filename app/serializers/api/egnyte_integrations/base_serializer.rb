class Api::EgnyteIntegrations::BaseSerializer < ActiveModel::Serializer
  attributes(
    :id,
    :company_id,
    :app_domain,
    :enabled,
    :connected,
    :deal_folder_tree,
    :account_folder_tree,
    :deals_folder_name
  )

  private

  def connected
    object.connected?
  end
end
