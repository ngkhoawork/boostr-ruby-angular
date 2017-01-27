class BPGenerator < BaseWorker
  def perform(bp_id)
    bp = Bp.find(bp_id)
    if bp.present?
      advertiser_id = Client.advertiser_type_id(bp.company)
      bp.company.users.each do |user|
        user.clients.by_type_id(advertiser_id).each do |client|
          bp_estimate_param = {
              client_id: client.id,
              user_id: user.id,
              estimate_seller: nil,
              estimate_mgr: nil,
              assumptions: nil,
              objectives: nil
          }
          bp.bp_estimates.create(bp_estimate_param)
          # if (bp_estimate = bp.bp_estimates.create(bp_estimate_param))
          #   bp.company.products.each do |product|
          #     bp_estimate_product_param = {
          #         product_id: product.id,
          #         estimate_seller: nil,
          #         estimate_mgr: nil,
          #     }
          #     bp_estimate.bp_estimate_products.create(bp_estimate_product_param)
          #   end
          # end
        end
      end
    end
  end
end