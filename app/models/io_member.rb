class IoMember < ActiveRecord::Base
  belongs_to :io
  belongs_to :user

  validates :user_id, :io_id, :share, presence:true
  def name
    user.name if user.present?
  end

  def as_json(options = {})
    super(options.merge(
              include: [
                  :user
              ]
          )
    )
  end
end
