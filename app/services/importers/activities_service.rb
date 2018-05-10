class Importers::ActivitiesService < Importers::BaseService
  def perform
    import
  end

  private

  def build_csv(row)
    Csv::Activity.new(row.merge(company_id: company_id))
  end

  def parser_options
    { force_simple_split: true, strip_chars_from_headers: /[\-"]/ }
  end

  def import_subject
    'Activity'
  end

  def import_source
    'ui'
  end
end
