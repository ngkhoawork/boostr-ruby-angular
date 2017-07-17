class WinRateByAdvertiserCategoryQuery
  def initialize(options = {})
    @options = options
  end

  def call
    related_deals
  end

  private

  attr_reader :options

  def related_deals
    Deal.find_by_sql([ win_rate_query, start_date: options[:start_date],
                       end_date: options[:end_date],
                       company_id: options[:company_id],
                       advertisers_ids: options[:advertisers_ids] ])
  end

  def win_rate_query
    'SELECT won.id,
             won.name,
             (cast(won_count as decimal(53,8)) / cast((won_count + lost_count) as DECIMAL(16,2))) AS win_rate
      FROM
        (SELECT options.id,
                options.name,
                COUNT(*) AS won_count
           FROM deals
           JOIN stages ON stages.id = deals.stage_id
           JOIN account_dimensions ON account_dimensions.id = deals.advertiser_id
           JOIN options ON options.id = account_dimensions.category_id
           WHERE deals.deleted_at IS NULL
             AND (stages.open IS FALSE)
             AND stages.probability = 100
             AND deals.closed_at BETWEEN :start_date AND :end_date
                 AND deals.company_id = :company_id
                 AND account_dimensions.id in (:advertisers_ids)
               GROUP BY options.id,
                        options.name) AS won
          JOIN
            (SELECT options.id,
                    options.name,
                    COUNT(*) AS lost_count
               FROM deals
               JOIN stages ON stages.id = deals.stage_id
               JOIN account_dimensions ON account_dimensions.id = deals.advertiser_id
               JOIN options ON options.id = account_dimensions.category_id
               WHERE deals.deleted_at IS NULL
                 AND (stages.open IS FALSE)
                 AND stages.probability = 0
                 AND deals.closed_at BETWEEN :start_date AND :end_date
                 AND deals.company_id = :company_id
                 AND account_dimensions.id in (:advertisers_ids)
               GROUP BY options.id,
                        options.name) AS lost ON won.id = lost.id
          ORDER BY won.name'.squish
  end

end