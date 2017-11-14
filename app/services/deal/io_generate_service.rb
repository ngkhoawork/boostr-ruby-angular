class Deal::IoGenerateService
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
    io_param = {
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
    if io = Io.create!(io_param)
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
  end

  def destroy_pmp
    if deal.io.present?
      deal.io.destroy
      deal.deal_products.product_type_of('Content-Fee').update_all(open: true)
    end
  end
end
