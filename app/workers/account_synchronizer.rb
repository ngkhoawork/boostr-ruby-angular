class AccountSynchronizer < BaseWorker
  def perform
    synchronize_account_dimensions
  end

  def synchronize_account_dimensions
    accounts = Client.all
    accounts.each do |account|
      account_dimension = AccountDimension.find_or_initialize_by(
        id: account.id
      )

      account_attributes = {
        id: account.id,
        name: account.name,
        account_type: global_type_id(account),
        category_id: account.client_category_id,
        subcategory_id: account.client_subcategory_id,
        holding_company_id: account.holding_company_id
      }

      next if account_dimension.attributes == account_attributes

      account_dimension.update(account_attributes)
    end
  end

  def global_type_id(account)
    if account.client_type_id
      if account.client_type_id == advertiser_type_id(account.company_id)
        Client::ADVERTISER
      elsif account.client_type_id == agency_type_id(account.company_id)
        Client::AGENCY
      end
    end
  end

  def account_type_options(company_id)
    @account_type_options ||= {}
    @account_type_options[company_id] ||= Field.find_by(company_id: company_id, name: 'Client Type').options.select(:id, :name)
  end

  def advertiser_type_id(company_id)
    account_type_options(company_id).find{|el| el.name == 'Advertiser' }.id
  end

  def agency_type_id(company_id)
    account_type_options(company_id).find{|el| el.name == 'Agency' }.id
  end
end
