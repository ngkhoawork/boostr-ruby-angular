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
             :team_and_split,
             :creator

  private

  def stage
    object.stage.name
  end

  def advertiser
    return '' unless object.advertiser
    object.advertiser.name
  end

  def agency
    return '' unless object.agency
    object.agency.name
  end

  def category
    return '' unless advertiser_category
    advertiser_category.name
  end

  def creator
    object.creator.slice('email', 'first_name', 'last_name') if object.creator
  end

  def team_and_split
    return [] if deal_members_with_non_zero_share.blank?
    deal_members_with_non_zero_share.pluck_to_hash(:email, :first_name, :last_name, :share)
  end

  def deal_members_with_non_zero_share
    object.deal_members.joins(:user).with_not_zero_share
  end

  def advertiser_category
    object.advertiser.client_category
  end

end