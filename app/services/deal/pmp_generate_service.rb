class Deal::PmpGenerateService
  attr_reader :deal, :stage, :pmp
  
  def initialize(deal)
    @deal = deal
    @stage = deal.stage
    @pmp = (deal && deal.pmp) || nil
  end

  def perform
    if !stage.open? && stage.probability == 100
      Pmp.transaction do
        generate_pmp
        generate_pmp_members()
        generate_pmp_items()
      end
    else
      destroy_pmp
    end
  end

  private

  def generate_pmp
    @pmp = Pmp.create!(pmp_params)
  end

  def generate_pmp_members
    deal.deal_members.each do |deal_member|
      if deal_member.user.present?
        PmpMember.create! pmp_member_params(deal_member)
      end
    end
  end
  
  def generate_pmp_items
    deal.deal_products.each do |deal_product|
      if deal_product.present?
        PmpItem.create! pmp_item_params(deal_product)
      end
    end
  end

  def destroy_pmp
    if pmp.present?
      pmp.destroy
      deal.deal_products.product_type_of('PMP').update_all(open: true)
    end
  end

  def pmp_params
    {
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
  end

  def pmp_member_params(deal_member)
    {
      pmp_id: pmp.id,
      user_id: deal_member.user_id,
      share: deal_member.share,
      from_date: deal.start_date,
      to_date: deal.end_date,
    }
  end

  def pmp_item_params(deal_product)
    {
      pmp_id: pmp.id,
      ssp_id: deal_product.ssp_id,
      ssp_deal_id: deal_product.ssp_deal_id,
      budget: deal_product.budget,
      budget_loc: deal_product.budget_loc,
      budget_delivered: 0,
      budget_delivered_loc: 0,
      budget_remaining: deal_product.budget,
      budget_remaining_loc: deal_product.budget_loc,
      pmp_type: deal_product.pmp_type
    }
  end
end
