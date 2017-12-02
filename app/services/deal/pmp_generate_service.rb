class Deal::PmpGenerateService
  attr_reader :deal, :stage
  
  def initialize(deal)
    @deal = deal
    @stage = deal.stage
  end

  def perform
    if !stage.open? && stage.probability == 100
      generate_pmp
    else
      destroy_pmp
    end
  end

  private

  def generate_pmp
    pmp_param = {
      company_id: deal.company_id,
      advertiser_id: deal.advertiser_id,
      agency_id: deal.agency_id,
      name: deal.name,
      budget: deal.budget.nil? ? 0 : deal.budget,
      budget_loc: deal.budget_loc.nil? ? 0 : deal.budget_loc,
      curr_cd: deal.curr_cd,
      start_date: deal.start_date,
      end_date: deal.end_date,
      deal_id: deal.id
    }
    if pmp = Pmp.create!(pmp_param)
      generate_pmp_members(pmp)
      generate_pmp_items(pmp)
    end
  end

  def generate_pmp_members(pmp)
    deal.deal_members.each do |deal_member|
      if deal_member.user.present?
        pmp_member_param = {
          pmp_id: pmp.id,
          user_id: deal_member.user_id,
          share: deal_member.share,
          from_date: deal.start_date,
          to_date: deal.end_date,
        }
        PmpMember.create!(pmp_member_param)
      end
    end
  end
  
  def generate_pmp_items(pmp)
    deal.deal_products.each do |deal_product|
      if deal_product
        pmp_item_param = {
            pmp_id: pmp.id,
            ssp_id: deal_product.ssp_id,
            ssp_deal_id: deal_product.ssp_deal_id,
            budget: deal_product.budget,
            budget_loc: deal_product.budget_loc,
            budget_delivered: 0,
            budget_delivered_loc: 0,
            budget_remaining: deal_product.budget,
            budget_remaining_loc: deal_product.budget_loc,
            is_guaranteed: deal_product.is_guaranteed
        }
        PmpItem.create!(pmp_item_param)
      end
    end
  end

  def destroy_pmp
    pmp = deal.pmp
    if pmp.present?
      pmp.destroy
      deal.deal_products.product_type_of('PMP').update_all(open: true)
    end
  end
end
