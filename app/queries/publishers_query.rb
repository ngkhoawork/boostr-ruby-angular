class PublishersQuery < BaseQuery
  def perform
    default_relation
      .by_company_id(options[:company_id])
      .by_comscore(options[:comscore])
      .by_stage_id(options[:publisher_stage_id])
      .by_type_id(options[:type_id])
      .by_team_id(options[:team_id])
      .by_created_at(options[:created_at_start], options[:created_at_end])
      .my_publishers(options[:my_publishers_bool], options[:current_user])
      .my_team_publishers(options[:my_team_publishers_bool], options[:current_user])
      .by_custom_fields(custom_field_inputs)
      .search_by_name(options[:q])
  end

  private

  def default_relation
    Publisher.all.extending(Scopes)
  end

  def custom_field_inputs
    options.select { |key, _value| key =~ /\Acustom_field_[\d]+\z/ }
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

    def by_created_at(created_at_start, created_at_end)
      return self if created_at_start.nil? || created_at_end.nil?

      where('created_at >= ? AND created_at <= ?', created_at_start, created_at_end)
    end

    def by_member_id(member_id)
      member_id.nil? ? self : joins(:publisher_members).where(publisher_members: { user_id: member_id })
    end

    def by_team_id(team_id)
      team_id.nil? ? self : joins(:users).where(users: { team_id: team_id })
    end

    def my_publishers(my_publishers_bool, current_user)
      return self if my_publishers_bool.nil? || current_user.nil?

      by_member_id(current_user.id)
    end

    def my_team_publishers(my_team_publishers_bool, current_user)
      return self if my_team_publishers_bool.nil? || current_user.nil?
      return by_lead_id(current_user) if current_user.leader?

      current_user.team_id.nil? ? none : by_team_id(current_user.team_id)
    end

    def by_lead_id(current_user)
      by_team_id Team.find_by(leader: current_user).id
    end

    def by_custom_fields(custom_field_inputs)
      return self if custom_field_inputs.blank?

      publisher_custom_field_options(custom_field_inputs)
        .inject(self) do |scope, (attr_name, attr_value)|
          scope.by_custom_field_attr(attr_name, attr_value)
        end
    end

    def search_by_name(q)
      q.present? ? super : self
    end

    def by_custom_field_attr(attr_name, attr_value)
      return self if attr_name.nil? || attr_value.nil?

      joins(:publisher_custom_field).where(publisher_custom_fields: { attr_name => attr_value })
    end

    def publisher_custom_field_options(opts)
      opts.inject({}) do |acc, (key, value)|
        custom_field_name = PublisherCustomFieldName.find_by(id: key.to_s.split('_')[-1])
        acc[custom_field_name.fetch_attr_name_for_publisher_custom_field] = value if custom_field_name
        acc
      end
    end
  end
end
