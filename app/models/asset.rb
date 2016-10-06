class Asset < ActiveRecord::Base
  belongs_to :attachable, polymorphic: true
  belongs_to :creator, class_name: 'User', foreign_key: 'created_by'

  attr_accessor :presigned_url

  ONE_HOUR = 60 * 60

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
