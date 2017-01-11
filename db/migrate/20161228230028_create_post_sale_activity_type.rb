class CreatePostSaleActivityType < ActiveRecord::Migration
  def change
    Company.all.each do |company|
      company.activity_types.create(
        name: 'Post Sale Meeting',
        action: 'had post sale meeting with',
        icon: '/assets/icons/post-sale-meeting.svg'
      )
    end
  end
end
