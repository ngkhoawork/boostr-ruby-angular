class AccountProductRevenueFactService < BaseService
  def perform
    clients.each do |client|

    end
  end

  private

  def content_fee_products
    @content_fee_products
  end

  def accounts
    @clients ||= AccountDimension.all
  end

  def time_dimensions
    @time_dimensions ||= TimeDimension.all
  end
end