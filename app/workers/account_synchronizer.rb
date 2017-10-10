class AccountSynchronizer < BaseWorker
  def perform
    synchronize_account_dimensions
  end

  private

  def synchronize_account_dimensions
    Client.find_each do |client|
      AccountDimensionUpdaterService.new(client: client).perform
    end
  end
end
