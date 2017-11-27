class PublishersQuery < BaseQuery
  def perform
    default_relation
      .by_company_id(options[:company_id])
      .by_comscore(options[:comscore])
      .by_stage_id(options[:publisher_stage_id])
      .by_type_id(options[:type_id])
      .by_team_id(options[:team_id])
      .by_created_at(options[:created_at])
      .my_publishers(options[:my_publishers_bool], options[:current_user])
      .my_team_publishers(options[:my_team_publishers_bool], options[:current_user])
      .by_custom_fields(options[:custom_field_names])
      .search_by_name(options[:q])
      .order('created_at DESC')
  end

  private

  def default_relation
    Publisher.all.extending(Scopes)
  end

  module Scopes
    def by_company_id(company_id)
      company_id.nil? ? self : where(company_id: company_id)
    end

    def by_comscore(comscore)
      comscore.nil? ? self : where(comscore: comscore)
    end

    def by_stage_id(stage_id)
      stage_id.nil? ? self : where(publisher_stage_id: stage_id)
    end

    def by_type_id(type_id)
      type_id.nil? ? self : where(type_id: type_id)
    end

    def by_created_at(created_at)
      created_at.nil? ? self : where('date(created_at) = ?', created_at.to_date)
    end

    def by_member_id(member_id)
      member_id.nil? ? self : joins(:publisher_members).where(publisher_members: { user_id: member_id })
    end

    def by_team_id(team_id)
      team_id.nil? ? self : joins(:users).where(users: { team_id: team_id })
    end

    def my_publishers(my_publishers_bool, current_user)
      return self unless my_publishers_bool && current_user&.id

      by_member_id(current_user.id)
    end

    def my_team_publishers(my_team_publishers_bool, current_user)
      return self unless my_team_publishers_bool && current_user&.team_id

      by_team_id(current_user.team_id)
    end

    def by_custom_fields(custom_field_name_opts)
      return self if custom_field_name_opts.nil?

      generate_custom_field_opts(custom_field_name_opts).inject(self) do |scope, custom_field_opt|
        scope.by_custom_field_attr(custom_field_opt[:attr_name], custom_field_opt[:attr_value])
      end
    end

    def by_custom_field_attr(attr_name, attr_value)
      return self if attr_name.nil? || attr_value.nil?

      joins(:publisher_custom_field).where(publisher_custom_fields: { attr_name => attr_value })
    end

    def generate_custom_field_opts(custom_field_name_opts)
      custom_field_name_opts.inject([]) do |acc, custom_field_name_opt|
        custom_field = PublisherCustomFieldName.find(custom_field_name_opt[:id])
        acc << {
          attr_name: custom_field.fetch_attr_name_for_publisher_custom_field,
          attr_value: custom_field_name_opt[:field_option]
        }
      end
    end

    def search_by_name(q)
      q.present? ? super : self
    end
  end
end
