class Api::Dataexport::AccountsController < Api::Dataexport::BaseController
  private

  def collection
    current_user.
      company.
      clients.
      includes(
        :parent_client,
        :holding_company,
        :client_category,
        :client_subcategory,
        :client_region,
        :client_segment
      )
  end

  def serializer_class
    ::Dataexport::AccountSerializer
  end
end
