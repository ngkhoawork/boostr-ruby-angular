class Api::InactivesController < ApplicationController
  respond_to :json

  def index
    render json: {
      inactives: inactives
    }
  end

  private

  def inactives
    inactives = []
    inactive_advertisers.each do |advertiser|
      last_activity = advertiser.activities.sort_by(&:happened_at).last
      sellers = advertiser.users.select do |user|
        user.user_type == SELLER ||
        user.user_type == SALES_MANAGER
      end

      inactives << {
        id: advertiser.id,
        client_name: advertiser.name,
        average_quarterly_spend: average_quarterly_spend(advertiser),
        open_pipeline: open_pipeline(advertiser),
        last_activity: last_activity.as_json(override: true, only: [:id, :name, :happened_at, :activity_type_name, :comment]),
        sellers: sellers.map(&:name)
      }
    end

    inactives.sort_by{|el| el[:average_quarterly_spend] * -1 }
  end

  def inactive_advertisers
    inactives = advertisers_with_consecutive_revenues_in_past - advertisers_with_current_revenue

    Client.where(id: inactives)
          .by_category(params[:category_id])
          .by_subcategory(params[:subcategory_id])
          .includes(:activities, :users)
  end

  def advertisers_with_current_revenue
    content_fee_product_budgets = ContentFeeProductBudget.where('content_fee_product_budgets.start_date >= ? AND content_fee_product_budgets.end_date <= ? AND content_fee_product_budgets.budget > 0', current_quarter.first, current_quarter.last).select(:content_fee_id)

    display_line_items = DisplayLineItem.where('display_line_items.start_date >= ? AND display_line_items.end_date <= ? AND display_line_items.budget > 0', current_quarter.first, current_quarter.last).select(:io_id)
    content_fees = ContentFee.where(id: content_fee_product_budgets.map(&:content_fee_id)).select(:io_id)

    ios = Io.where(id: content_fees.map(&:io_id) + display_line_items.map(&:io_id), company_id: current_user.company.id).select(:advertiser_id)
    ios.map(&:advertiser_id)
  end

  def advertisers_with_consecutive_revenues_in_past
    advertisers = []
    previous_quarters.each_with_index do |qtr, index|
      content_fee_product_budgets = ContentFeeProductBudget.where('content_fee_product_budgets.start_date >= ? AND content_fee_product_budgets.end_date <= ? AND content_fee_product_budgets.budget > 0', qtr.first, qtr.last).select(:content_fee_id)

      display_line_items = DisplayLineItem.where('display_line_items.start_date >= ? AND display_line_items.end_date <= ? AND display_line_items.budget > 0', qtr.first, qtr.last).select(:io_id)
      content_fees = ContentFee.where(id: content_fee_product_budgets.map(&:content_fee_id)).select(:io_id)

      ios = Io.where(id: content_fees.map(&:io_id) + display_line_items.map(&:io_id), company_id: current_user.company.id).select(:advertiser_id)

      if index == 0
        advertisers.concat ios.map(&:advertiser_id)
      else
        advertisers.concat(ios.map(&:advertiser_id) & advertisers)
      end
    end

    advertisers
  end

  def average_quarterly_spend(advertiser)
    total_budget = 0
    ios = Io.where(advertiser_id: advertiser.id).includes(:io_members, :content_fees, :display_line_items)
    ios.each do |io|
      advertiser.users.each do |user|
        next unless io.io_members.map(&:user_id).include?(user.id)
        total_budget += io.effective_revenue_budget(user, full_time_period.first, full_time_period.last)
      end
    end

    (total_budget / qtr_offset).round(0)
  end

  def open_pipeline(advertiser)
    pipeline = 0
    advertiser.users.each do |user|
      pipeline += user.unweighted_pipeline(current_quarter.first, current_quarter.last)
    end

    pipeline.round(0)
  end

  def advertiser_type_id
    Client.advertiser_type_id(current_user.company)
  end

  def company
    @company ||= current_user.company
  end

  def full_time_period
    first = Date.today.beginning_of_quarter << (qtr_offset * 3)
    last = Date.today
    first..last
  end

  def current_quarter
    first = Date.today.beginning_of_quarter
    last = Date.today
    first..last
  end

  def lookback_window
    first = Date.today.beginning_of_quarter << (qtr_offset * 3)
    last = Date.today.end_of_quarter << (1 * 3)
    first..last
  end

  def previous_quarters
    quarters = []
    qtr_offset.times do
      first = Date.today.beginning_of_quarter << ((qtr_offset - quarters.length) * 3)
      last = Date.today.end_of_quarter << ((qtr_offset - quarters.length) * 3)
      quarters << (first..last)
    end
    quarters
  end

  def qtr_offset
    (params[:qtrs] || 2).to_i
  end
end
