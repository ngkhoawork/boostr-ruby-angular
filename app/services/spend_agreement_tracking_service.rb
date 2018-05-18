class SpendAgreementTrackingService < BaseService
  def track_deals
    return unbind_non_match_deals unless auto_tracked?
    add_matching_deals if auto_tracked?
  end

  def track_spend_agreements
    add_matching_spend_agreements
  end

  def untracked_deals
    untracked_deal_ids
  end

  def possible_agreements
    SpendAgreement.where(id: any_matching_spend_agreement_ids.uniq - deal.spend_agreements.ids)
  end

  private

  def unbind_non_match_deals
    deals_to_unbind.delete_all
  end

  def deals_to_unbind
    spend_agreement.spend_agreement_deals.where.not(deal_id: matching_deal_ids)
  end

  def add_matching_spend_agreements
    deal.spend_agreement_deals.where.not(spend_agreement_id: matching_spend_agreement_ids).delete_all
    deal.spend_agreement_deals.create(hash_build(:spend_agreement_id, (matching_spend_agreement_ids.uniq - deal.spend_agreements.ids)))
  end

  def add_matching_deals
    unbind_non_match_deals
    spend_agreement.spend_agreement_deals.create(hash_build(:deal_id, untracked_deal_ids))
  end

  def matching_deals
    @matching_deal_ids ||= spend_agreement.company.deals
      .for_time_period(spend_agreement.start_date, spend_agreement.end_date)
      .by_advertisers(spend_agreement.all_brands)
      .by_agencies(spend_agreement.all_agencies)
  end

  def matching_deal_ids
    matching_deals.ids
  end

  def untracked_deal_ids
    matching_deals.where.not(id: spend_agreement.deals.ids).ids
  end

  def auto_tracked?
    !spend_agreement.manually_tracked?
  end

  def hash_build(key, arr)
    arr.map{|id| {key => id} }
  end

  def matching_spend_agreement_ids
    @matching_spend_agreement_ids ||= (
    if deal.advertiser_id && deal.agency_id.nil?
      advertiser_match_agreement_ids -
      any_agency_agreements.ids -
      any_holding_agreement.ids
    elsif deal.advertiser_id && deal.agency_id
      advertiser_match_agreement_ids & agency_match_agreement_ids
    end
    )
  end

  def any_matching_spend_agreement_ids
    if deal.advertiser_id && deal.agency_id.nil?
      all_advertiser_match_agreement_ids - all_any_agency_agreements_ids - all_any_holding_agreement_ids
    elsif deal.advertiser_id && deal.agency_id
      all_advertiser_match_agreement_ids & all_agency_match_agreements_ids
    end
  end

  def advertiser_match_agreement_ids
    (
      advertiser_only_match_agreements.ids +
      parent_client_without_child_agreements.ids +
      parent_client_as_deal_advertiser.ids +
      agreements_without_child_and_parent_ids
    ).uniq
  end

  def agency_match_agreement_ids
    (
      agency_match_agreements.ids +
      holding_company_agreements.ids +
      no_agency_agreement.ids
    ).uniq
  end

  def all_any_agency_agreements_ids
    any_agency_agreements(manual_tracked: [true, false]).ids
  end

  def all_any_holding_agreement_ids
    any_holding_agreement(manual_tracked: [true, false]).ids
  end

  def all_agency_match_agreements_ids
    (
      agency_match_agreements(manual_tracked: [true, false]).ids +
      holding_company_agreements(manual_tracked: [true, false]).ids +
      no_agency_agreement(manual_tracked: [true, false]).ids
    ).uniq
  end

  def all_advertiser_match_agreement_ids
    (
      advertiser_only_match_agreements(manual_tracked: [true, false]).ids +
      parent_client_without_child_agreements(manual_tracked: [true, false]).ids +
      parent_client_as_deal_advertiser(manual_tracked: [true, false]).ids +
      agreements_without_child_and_parent_ids(manual_tracked: [true, false])
    ).uniq
  end

  def agreements_without_child_and_parent_ids(manual_tracked: false)
    no_child_brand_agreement(manual_tracked: manual_tracked).ids & no_parent_company_agreement(manual_tracked: manual_tracked).ids
  end

  def no_child_brand_agreement(manual_tracked: false)
    SpendAgreement
      .for_time_period(deal.start_date, deal.end_date)
      .where(manually_tracked: manual_tracked)
      .where('spend_agreements.company_id = ?', deal.company_id)
      .joins('LEFT JOIN spend_agreement_clients ON spend_agreement_clients.spend_agreement_id = spend_agreements.id')
      .joins('LEFT JOIN account_dimensions ON account_dimensions.id = spend_agreement_clients.client_id')
      .group(:id)
      .having('count(CASE WHEN account_dimensions.account_type = 10 THEN 1 END)=0 OR count(spend_agreement_clients) = 0')
      .distinct
  end

  def no_parent_company_agreement(manual_tracked: false)
    SpendAgreement
        .for_time_period(deal.start_date, deal.end_date)
        .where(manually_tracked: manual_tracked)
        .where('spend_agreements.company_id = ?', deal.company_id)
        .joins('LEFT JOIN spend_agreement_parent_companies ON spend_agreement_parent_companies.spend_agreement_id = spend_agreements.id')
        .joins('LEFT JOIN account_dimensions ON account_dimensions.id = spend_agreement_parent_companies.client_id')
        .group(:id)
        .having('count(CASE WHEN account_dimensions.account_type = 10 THEN 1 END) = 0 OR count(spend_agreement_parent_companies) = 0')
        .distinct
  end

  def no_agency_agreement(manual_tracked: false)
    SpendAgreement
      .for_time_period(deal.start_date, deal.end_date)
      .where(manually_tracked: manual_tracked)
      .where('spend_agreements.company_id = ?', deal.company_id)
      .joins('LEFT JOIN spend_agreement_clients ON "spend_agreement_clients"."spend_agreement_id" = "spend_agreements"."id"')
      .joins('LEFT JOIN account_dimensions ON account_dimensions.id = spend_agreement_clients.client_id')
      .by_holding_company(deal.agency.holding_company_id)
      .group(:id)
      .having('count(CASE WHEN account_dimensions.account_type = 11 THEN 1 END) = 0 OR count(spend_agreement_clients) = 0')
      .distinct
  end

  def any_holding_agreement(manual_tracked: false)
    SpendAgreement
      .for_time_period(deal.start_date, deal.end_date)
      .where(manually_tracked: manual_tracked)
      .where('spend_agreements.company_id = ?', deal.company_id)
      .where.not(holding_company: nil)
      .distinct
  end

  def holding_company_agreements(manual_tracked: false)
    SpendAgreement
      .for_time_period(deal.start_date, deal.end_date)
      .where(manually_tracked: manual_tracked)
      .where('spend_agreements.company_id = ?', deal.company_id)
      .by_holding_company(deal.agency.holding_company_id)
      .where.not(id: no_agency_match_agreements(manual_tracked: manual_tracked).ids)
      .distinct
  end

  def any_agency_agreements(manual_tracked: false)
    SpendAgreement
      .joins(:spend_agreement_clients)
      .joins('JOIN account_dimensions ON account_dimensions.id = spend_agreement_clients.client_id')
      .for_time_period(deal.start_date, deal.end_date)
      .where(manually_tracked: manual_tracked)
      .where('spend_agreements.company_id = ?', deal.company_id)
      .where('account_dimensions.account_type = ?', 11)
      .distinct
  end

  def parent_client_without_child_agreements(manual_tracked: false)
    SpendAgreement
      .joins(:spend_agreement_parent_companies)
      .for_time_period(deal.start_date, deal.end_date)
      .where(manually_tracked: manual_tracked)
      .where('spend_agreements.company_id = ?', deal.company_id)
      .where('spend_agreement_parent_companies.client_id = ?', deal.advertiser.parent_client_id)
      .where.not(id: parent_client_no_match_child)
      .distinct
  end

  def parent_client_as_deal_advertiser(manual_tracked: false)
    SpendAgreement
      .joins(:spend_agreement_parent_companies)
      .for_time_period(deal.start_date, deal.end_date)
      .where(manually_tracked: manual_tracked)
      .where('spend_agreements.company_id = ?', deal.company_id)
      .where('spend_agreement_parent_companies.client_id = ?', deal.advertiser_id)
      .where.not(id: agreements_with_children)
      .distinct
  end

  def agreements_with_children(manual_tracked: false)
    SpendAgreement
      .joins(:spend_agreement_clients)
      .joins('JOIN account_dimensions ON account_dimensions.id = spend_agreement_clients.client_id')
      .for_time_period(deal.start_date, deal.end_date)
      .where(manually_tracked: manual_tracked)
      .where('spend_agreements.company_id = ?', deal.company_id)
      .where('account_dimensions.account_type = ?', 10)
      .distinct
      .ids
  end

  def parent_client_no_match_child(manual_tracked: false)
    SpendAgreement
      .joins(:spend_agreement_parent_companies)
      .joins(:spend_agreement_clients)
      .joins('JOIN account_dimensions ON account_dimensions.id = spend_agreement_clients.client_id')
      .for_time_period(deal.start_date, deal.end_date)
      .where(manually_tracked: manual_tracked)
      .where('spend_agreements.company_id = ?', deal.company_id)
      .where('spend_agreement_parent_companies.client_id = ?', deal.advertiser.parent_client_id)
      .where('account_dimensions.account_type = ?', 10)
      .where.not('spend_agreement_clients.client_id = ?', deal.advertiser_id)
      .distinct
  end

  def advertiser_match_agreements(manual_tracked: false)
    SpendAgreement
      .joins(:spend_agreement_clients)
      .joins('JOIN account_dimensions ON account_dimensions.id = spend_agreement_clients.client_id')
      .for_time_period(deal.start_date, deal.end_date)
      .where(manually_tracked: manual_tracked)
      .where('spend_agreements.company_id = ?', deal.company_id)
      .where('account_dimensions.account_type = ?', 10)
      .where('spend_agreement_clients.client_id = ?', deal.advertiser_id)
      .distinct
  end

  def agency_match_agreements(manual_tracked: false)
    SpendAgreement
      .joins(:spend_agreement_clients)
      .joins('JOIN account_dimensions ON account_dimensions.id = spend_agreement_clients.client_id')
      .for_time_period(deal.start_date, deal.end_date)
      .where(manually_tracked: manual_tracked)
      .where('spend_agreements.company_id = ?', deal.company_id)
      .where('account_dimensions.account_type = ?', 11)
      .by_client_id(deal.agency_id)
      .by_holding_company(deal.agency.holding_company_id)
      .distinct
  end

  def no_agency_match_agreements(manual_tracked: false)
    SpendAgreement
      .joins(:spend_agreement_clients)
      .joins('JOIN account_dimensions ON account_dimensions.id = spend_agreement_clients.client_id')
      .for_time_period(deal.start_date, deal.end_date)
      .where(manually_tracked: manual_tracked)
      .where('spend_agreements.company_id = ?', deal.company_id)
      .where('account_dimensions.account_type = ?', 11)
      .where.not('spend_agreement_clients.client_id = ?', deal.agency_id)
      .by_holding_company(deal.agency.holding_company_id)
      .distinct
  end

  def advertiser_match_agreements_ids
    advertiser_match_agreements.pluck(:id)
  end

  def advertiser_only_match_agreements(manual_tracked: false)
    SpendAgreement
      .joins(:spend_agreement_clients)
      .joins('JOIN account_dimensions ON account_dimensions.id = spend_agreement_clients.client_id')
      .for_time_period(deal.start_date, deal.end_date)
      .where(manually_tracked: manual_tracked)
      .where('spend_agreements.company_id = ?', deal.company_id)
      .where('account_dimensions.account_type = ?', 10)
      .where('spend_agreement_clients.client_id = ?', deal.advertiser_id)
      .distinct
  end

  def parent_advertiser_match_agreements(manual_tracked: false)
    SpendAgreement
        .joins(:spend_agreement_parent_companies)
        .for_time_period(deal.start_date, deal.end_date)
        .where(manually_tracked: manual_tracked)
        .where('company_id = :company_id AND spend_agreement_parent_companies.client_id = :advertiser_id
                AND spend_agreement.id NOT IN (:agency_match_agreements)',
               company_id: deal.company_id,
               advertiser_id: deal.advertiser_id,
               agency_match_agreements: agency_match_agreements_ids)
        .where.not(id: deal.spend_agreements.ids)
        .distinct
  end

  def agency_match_agreements_ids
    agency_match_agreements.pluck(:id)
  end

  def advertiser_only_match_agreements_ids
    advertiser_only_match_agreements.pluck(:id)
  end

  def total_match_agreements_ids
    advertiser_match_agreements_ids & agency_match_agreements_ids
  end
end
