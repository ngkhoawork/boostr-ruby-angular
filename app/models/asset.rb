class Asset < ActiveRecord::Base
  belongs_to :company
  belongs_to :attachable, polymorphic: true
  belongs_to :creator, class_name: 'User', foreign_key: 'created_by'

  attr_accessor :presigned_url

  before_destroy :delete_from_s3, prepend: true

  ONE_HOUR = 60 * 60

  scope :for_company, -> id { where(company_id: id) }
  scope :unmapped, -> { where(attachable_id: nil) }

  def presigned_url
    obj = S3_BUCKET.object(self.asset_file_name)
    if obj.nil?
      return ""
    end
    return obj.presigned_url(:get, expires_in: ONE_HOUR)
  end

  def as_json(options = {})
    super(options.merge(
      include: {
        creator: { only: [:id], methods: :name }
      },
      methods: [:presigned_url]
    ))
  end

  def delete_from_s3
    obj = S3_BUCKET.object(self.asset_file_name)
    obj.delete if obj
  end
end
