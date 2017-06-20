class UserMailer < ApplicationMailer
  include ActionView::Helpers::NumberHelper
  default from: 'boostr <noreply@boostrcrm.com>'
 
  def close_email(recipients, subject, deal)
    @deal = deal
    mail(to: recipients, subject: subject)
  end

  def stage_changed_email(recipients, subject, deal_id)
    @deal = Deal.find(deal_id)
    mail(to: recipients, subject: subject)
  end

  def new_deal_email(recipients, deal_id)
    @deal = Deal.find(deal_id)
    subject = "A new #{@deal.budget.nil? ? '$0' : number_to_currency((@deal.budget).round, :precision => 0)} deal for #{@deal.advertiser.present? ? @deal.advertiser.name : ""} just added to the pipeline"
    mail(to: recipients, subject: subject)
  end

  def ealert_email(recipients, ealert_id, deal_id, comment, user_id = nil)
    @user = User.find(user_id) if user_id.present?
    @deal = Deal.find(deal_id)
    @deal_fields = []
    @comment = comment
    @deal_products = @deal.deal_products.as_json({
      include: {
        deal_product_budgets: {
          methods: [:budget_percentage]
        },
        deal_product_cf: {},
        product: {
          only: [:id, :name]
        }
      }
    }).map do |deal_product|
      deal_product['deal_product_fields'] = []
      deal_product
    end

    ealert = Ealert.find(ealert_id).as_json({include: {
        ealert_custom_fields:  {
          include: {
            subject: {}
          }
        },
      }
    })
    deal_settings_fields = @deal.company.fields.where(subject_type: 'Deal').pluck(:id, :name)

    subject = "eAlert - #{@deal.name}"

    position_fields = [
      {
        'name' => 'agency',
        'label' => 'Agency',
        'value' => (@deal.agency ? @deal.agency.name : '')
      },
      {
        'name' => 'deal_type',
        'label' => 'Deal Type',
        'value' => @deal.get_option_value_from_raw_fields(deal_settings_fields, 'Deal Type')
      },
      {
        'name' => 'source_type',
        'label' => 'Source Type',
        'value' => @deal.get_option_value_from_raw_fields(deal_settings_fields, 'Deal Source')
      },
      {
        'name' => 'next_steps',
        'label' => 'Next Steps',
        'value' => @deal.next_steps
      },
      {
        'name' => 'closed_reason',
        'label' => 'Closed Reason',
        'value' => @deal.get_option_value_from_raw_fields(deal_settings_fields, 'Close Reason')
      },
      {
        'name' => 'intiative',
        'label' => 'Initiative',
        'value' => (@deal.initiative ? @deal.initiative.name : '')
      }
    ]
    
    position_fields.each do |position_field|
      if ealert[position_field['name']] && ealert[position_field['name']] > 0
        position_field['position'] = ealert[position_field['name']]
        @deal_fields << position_field
      end
    end
    deal_custom_field = @deal.deal_custom_field.as_json
    ealert['ealert_custom_fields'].each do |ealert_custom_field|
      if ealert_custom_field['subject_type'] == 'DealCustomFieldName' && ealert_custom_field['position'] > 0
        field_name = ealert_custom_field['subject']['field_type'] + ealert_custom_field['subject']['field_index'].to_s
        value = deal_custom_field && deal_custom_field[field_name] ? deal_custom_field[field_name] : nil

        case ealert_custom_field['subject']['field_type']
          when 'number'
            value = value || 0
            value = number_with_precision(value, :precision => 2, :delimiter => ',')
          when 'number_4_dec'
            value = value || 0
            value = number_with_precision(value, :precision => 4, :delimiter => ',')
          when 'integer'
            value = value || 0
            value = number_with_precision(value, :precision => 0, :delimiter => ',')
          when 'currency'
            value = value || 0
            value = '$' + number_with_precision(value, :precision => 2, :delimiter => ',').to_s
          when 'percentage'
            value = value || 0
            value = number_with_precision(value, :precision => 0, :delimiter => ',') + '%'
          when 'datetime'
            value = value ? value.strftime('%b %d, %Y') : ''
          when 'boolean'
            value = value || false
            value = value ? 'Yes' : 'No'
          when 'sum'
            value = value || 0
            value = number_with_precision(value, :precision => 0, :delimiter => ',')
        end
        position_field = {
          'name' => field_name,
          'label' => ealert_custom_field['subject']['field_label'],
          'value' => value,
          'position' => ealert_custom_field['position']
        }
        @deal_fields << position_field
      elsif ealert_custom_field['subject_type'] == 'DealProductCfName' && ealert_custom_field['position'] > 0
        field_name = ealert_custom_field['subject']['field_type'] + ealert_custom_field['subject']['field_index'].to_s
        @deal_products = @deal_products.map do |deal_product|
          value = deal_product['deal_product_cf'] && deal_product['deal_product_cf'][field_name] ? deal_product['deal_product_cf'][field_name] : nil
          case ealert_custom_field['subject']['field_type']
            when 'number'
              value = value || 0
              value = number_with_precision(value, :precision => 2, :delimiter => ',')
            when 'number_4_dec'
              value = value || 0
              value = number_with_precision(value, :precision => 4, :delimiter => ',')
            when 'integer'
              value = value || 0
              value = number_with_precision(value, :precision => 0, :delimiter => ',')
            when 'currency'
              value = value || 0
              value = '$' + number_with_precision(value, :precision => 2, :delimiter => ',').to_s
            when 'percentage'
              value = value || 0
              value = number_with_precision(value, :precision => 0, :delimiter => ',') + '%'
            when 'datetime'
              value = value ? value.strftime('%b %d, %Y') : ''
            when 'boolean'
              value = value || false
              value = value ? 'Yes' : 'No'
            when 'sum'
              value = value || 0
              value = number_with_precision(value, :precision => 0, :delimiter => ',')
          end
          position_field = {
            'name' => field_name,
            'label' => ealert_custom_field['subject']['field_label'],
            'value' => value,
            'position' => ealert_custom_field['position']
          }
          deal_product['deal_product_fields'] << position_field
          deal_product
        end
      end
    end
    @deal_fields = @deal_fields.sort_by { |hash| hash['position'].to_i }
    @deal_products = @deal_products.map do |deal_product|
      deal_product['deal_product_fields'] = deal_product['deal_product_fields'].sort_by { |hash| hash['position'].to_i }
      deal_product
    end
    @sales_team = ''
    @sales_team = @deal.deal_members.map{ |deal_member| deal_member.user.name + ' (' + deal_member.share.to_s + '%)' }.join(', ') if @deal.deal_members.count > 0
    if user_id.present?
      mail(to: recipients, from: @user.email, subject: subject)
    else
      mail(to: recipients, subject: subject)
    end
  end
end
