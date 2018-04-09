class StagesQuery < BaseQuery
  def perform
    default_relation
      .by_company_id(options[:company_id])
      .by_sales_process_id(sales_process_id)
      .is_active(options[:active])
      .is_open(options[:open])
  end

  private

  def sales_process_id
    if options[:team_id]
      team.sales_process_id || default_sales_process&.id
    elsif options[:sales_process_id]
      options[:sales_process_id]
    elsif options[:current_team]
      current_user&.current_team&.sales_process_id || default_sales_process&.id
    else
      'all'
    end
  end

  def default_sales_process
    company.default_sales_process
  end

  def team
    @_team ||= company.teams.find(options[:team_id])
  end

  def company
    @_company ||= Company.find(options[:company_id])
  end

  def current_user
    options[:current_user]
  end

  def default_relation
    Stage.all.extending(Scopes)
  end

  module Scopes
    def by_company_id(company_id)
      company_id.nil? ? self : where(company_id: company_id)
    end

    def by_sales_process_id(sales_process_id)
      if sales_process_id == 'all'
        self
      elsif sales_process_id.nil?
        where(sales_process_id: -1)
      else
        where(sales_process_id: sales_process_id)
      end
    end

    def is_active(status)
      status.nil? ? self : where(active: status)
    end
  end
end

