class Dataexport::DealSerializer < ActiveModel::Serializer
  attributes :id, :name, :advertiser, :agency, :start_date, :end_date, :budget_usd, :budget, :created,
             :last_updated, :stage_id, :stage_name, :type, :source, :next_steps, :closed_date, :open,
             :currency, :initiative_id, :closed_text, :custom_fields

  def advertiser
    object.advertiser&.name
  end

  def agency
    object.agency&.name
  end

  def budget_usd
    object.budget
  end

  def budget
    object.budget_loc
  end

  def created
    object.created_at
  end

  def last_updated
    object.updated_at
  end

  def stage_name
    object.stage&.name
  end

  def type
    object.deal_type
  end

  def source
    object.source_type
  end

  def closed_date
    object.closed_at
  end

  def currency
    object.curr_cd
  end

  def closed_text
    object.closed_reason_text
  end

  def custom_fields
    object.company.deal_custom_field_names.reduce({}) do |result, field|
      result.merge(field.field_label.downcase.gsub(' ', '_') => object&.deal_custom_field&.public_send(field.field_name))
    end
  end
end
