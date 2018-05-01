class Email::EalertTemplateService
  def initialize(ealert_template, record, recipients, comment, attached_asset_ids)
    @ealert_template = ealert_template
    @record = record
    @recipients = recipients
    @comment = comment
    @attached_asset_ids = attached_asset_ids || []

    if @ealert_template.subject_class != @record.class
      raise ArgumentError, "#{@ealert_template.type} can not process #{@record.class} record"
    end
  end

  delegate :subject_decorator_class, :fields_with_position, to: :@ealert_template

  def perform
    ContractMailer.ealert(@recipients, @record.id, @record.name, fields_hash, assets_hash, @comment).deliver_now
  end

  def fields_hash
    fields_with_position.inject([]) do |acc, field|
      acc << {
        label: field.label,
        value: decorated_record.public_send(field.name)
      }
    end
  end

  def assets_hash
    @record.assets.where(id: @attached_asset_ids).inject([]) do |acc, asset|
      acc << {
        name: asset.original_file_name,
        url: asset.presigned_url
      }
    end
  end

  def decorated_record
    @decorated_record ||= subject_decorator_class.new(@record)
  end
end
