class Importers::ActivePmpItemImportService < Importers::BaseService

  def perform
    open_file
    import
  end

  private

  def build_csv(row)
    opts = {
        name: row[:name],
        full_name: row[:full_name],
        deal_id: row[:deal_id],
        ssp: row[:ssp],
        pmp_type: row[:pmp_type],
        product_name: row[:product],
        product_level1: row[:product_level1],
        product_level2: row[:product_level2],
        start_date: row[:start_date],
        end_date: row[:end_date],
        budget: row[:budget],
        delivered: row[:delivered]
    }
    if cf_required.any?
      params = {
        raises: []
      }
      cf_required.each do |key|
        if row[key].blank?
          params[:raises] << "Invalid required #{key} field"
        end
        params[key]= row[key]
      end
      opts[:custom_fields_required] = params if params.present?
    end
    if cf_optional.any?
      params = {}
      cf_optional.each do |key|
        next if row[key].blank?
        params[key]= row[key]
      end
      opts[:custom_fields_optional] = params if params.present?
    end
    opts[:company] = company
    Csv::ActivePmpItem.new(opts)
  end

  def company
    Company.find_by(id: company_id)
  end

  def cf_required
    @_cf_required ||= active_cf.required.map(&:to_csv_header)
  end

  def cf_optional
    @_cf_optional ||= active_cf.optional.map(&:to_csv_header)
  end

  def active_cf
    @_active_cf ||= company&.custom_field_names.active.where(subject_type:'PmpItem')
  end

  def parser_options
    { force_simple_split: true, strip_chars_from_headers: /[\-"]/ }
  end

  def import_subject
    'ActivePmpItem'
  end

  def import_source
    'ui'
  end
end
