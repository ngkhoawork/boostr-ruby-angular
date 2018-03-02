class Deal::IoGenerateService
  attr_reader :deal, :stage
  
  def initialize(deal)
    @deal = deal
    @stage = deal.stage
  end

  def perform
    if !stage.open? && stage.probability == 100
      generate_io
    else
      destroy_io
    end
  end

  private

  def generate_io
    if io = Io.create!(io_param)
      generate_io_members(io)
      generate_content_fees(io)
      generate_costs(io)
    end
  end

  def generate_io_members(io)
    deal.deal_members.each do |deal_member|
      if deal_member.user.present?
        io_member_param = {
          io_id: io.id,
          user_id: deal_member.user_id,
          share: deal_member.share,
          from_date: deal.start_date,
          to_date: deal.end_date,
        }
        IoMember.create!(io_member_param)
      end
    end
  end

  def generate_content_fees(io)
    deal.deal_products.product_type_of('Content-Fee').created_asc.each do |deal_product|
      content_fee_param = {
        io_id: io.id,
        product_id: deal_product.product.id,
        budget: deal_product.budget,
        budget_loc: deal_product.budget_loc
      }
      content_fee = ContentFee.create(content_fee_param)
      deal_product.update_columns(open: false)
    end
  end

  def generate_costs(io)
    deal.deal_products.created_asc.each do |deal_product|
      margin = deal_product.product&.margin || 100
      budget = deal_product.budget * margin / 100.0
      budget_loc = deal_product.budget_loc * margin / 100.0
      cost_monthly_amounts = cost_amounts_param(deal_product, margin)
      cost_param = {
        io_id: io.id,
        product_id: deal_product.product.id,
        budget: budget,
        budget_loc: budget_loc,
        is_estimated: true,
        cost_monthly_amounts_attributes: cost_monthly_amounts
      }
      cost = Cost.create(cost_param)
    end
  end

  def cost_amounts_param(deal_product, margin)
    deal_product.deal_product_budgets.inject([]) do |result, deal_product_budget|
      monthly_budget = deal_product_budget.budget * margin / 100.0
      monthly_budget_loc = deal_product_budget.budget_loc * margin / 100.0
      result << {
        budget: monthly_budget,
        budget_loc: monthly_budget_loc,
        start_date: deal_product_budget.start_date,
        end_date: deal_product_budget.end_date
      }
    end
  end

  def io_param
    @_io_param ||= {
        advertiser_id: deal.advertiser_id,
        agency_id: deal.agency_id,
        budget: deal.budget.nil? ? 0 : deal.budget,
        budget_loc: deal.budget_loc.nil? ? 0 : deal.budget_loc,
        curr_cd: deal.curr_cd,
        start_date: deal.start_date,
        end_date: deal.end_date,
        name: deal.name,
        io_number: deal.id,
        external_io_number: nil,
        company_id: deal.company_id,
        deal_id: deal.id
    }
  end

  def destroy_io
    if deal.io.present?
      deal.io.destroy
      deal.deal_products.product_type_of('Content-Fee').update_all(open: true)
    end
  end
end
