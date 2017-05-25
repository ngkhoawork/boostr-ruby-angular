class ProductDimensionUpdaterWorker < BaseWorker
  def perform
    ProductDimensionUpdaterService.new.perform
  end
end