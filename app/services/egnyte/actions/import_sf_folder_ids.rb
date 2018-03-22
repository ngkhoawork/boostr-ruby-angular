class Egnyte::Actions::ImportSfFolderIds
  OBJECT_TYPE_MAPPER = {
    'Accounts' => 'Client',
    'Opportunities' => 'Deal'
  }.freeze

  attr_reader :errors

  def initialize(file_path)
    @file_path = file_path
    @errors = []
  end

  def perform
    row_num = 1

    SmarterCSV.process(file, parser_options).each do |chunk|
      chunk.each do |row|
        begin
          raise 'Unknown subject_type' unless match_subject_type(row[:sf_object_type])

          attrs = build_attrs(row)

          raise 'Some attr is nil' if attrs.values.include?(nil)

          record = EgnyteFolder.new(attrs)

          add_errors(row_num, row, attrs, record.errors.full_messages) unless record.save
        rescue Exception => e
          add_errors(row_num, row, nil, [e.message])
        ensure
          row_num += 1
        end
      end
    end
  end

  private

  def build_attrs(row)
    {
      uuid: clean_double_quotes(row[:egnyte_folder_id]),
      subject_type: match_subject_type(row[:sf_object_type]),
      subject_id: match_subject_id(row[:sf_object_type], row[:sf_object_id])
    }
  end

  def match_subject_type(sf_type)
    OBJECT_TYPE_MAPPER[clean_double_quotes(sf_type)]
  end

  def match_subject_id(sf_type, sf_id)
    subject_class(sf_type)
      .where(salesforce_id: clean_double_quotes(sf_id))
      .limit(1)
      .select(:id)
      .first
      &.id
  end

  def subject_class(sf_type)
    match_subject_type(sf_type).constantize
  end

  def add_errors(row_num, row, attrs, error_messages)
    @errors << {
      row_num: row_num,
      row: row,
      attrs: attrs,
      error_messages: error_messages
    }
  end

  def file
    @file ||= File.open(@file_path, 'r:bom|utf-8')
  end

  def parser_options
    { chunk_size: 1000, strip_chars_from_headers: /[\-"]/ }
  end

  def clean_double_quotes(str)
    str.gsub(/\"/, '')
  end
end
