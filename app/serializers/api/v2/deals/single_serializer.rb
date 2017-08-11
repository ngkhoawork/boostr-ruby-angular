class Api::V2::Deals::SingleSerializer < ActiveModel::Serializer
  attributes :id,
             :name,
             :stage,
             :budget_loc,
             :curr_cd,
             :start_date,
             :end_date,
             :advertiser,
             :category,
             :agency,
             :team_and_split

  private

  def stage
    object.stage.name
  end

  def advertiser
    object.advertiser.name || ''
  end

  def agency
    object.agency.name || ''
  end

  def category
    return '' unless advertiser_category
    advertiser_category.name
  end

  def team_and_split
    return [] if deal_members_with_non_zero_share.blank?
    deal_members_with_non_zero_share.pluck_to_hash(:email, :share)
  end

  def deal_members_with_non_zero_share
    object.deal_members.joins(:user).with_not_zero_share
  end

  def advertiser_category
    object.advertiser.client_category
  end

end