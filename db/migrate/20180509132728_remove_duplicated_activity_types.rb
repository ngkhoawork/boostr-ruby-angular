class RemoveDuplicatedActivityTypes < ActiveRecord::Migration
  def change
    Company.find_each do |company|
      act_type_names.each do |type_name|
        act_type = company.activity_types.where(name: type_name).order(:created_at)

        if act_type.count > 1
          activity_with_dup_act_type = Activity.find_by(activity_type_id: act_type.last.id)
          activity_with_dup_act_type.update(activity_type_id: act_type.first.id) if activity_with_dup_act_type

          act_type.drop(1).map(&:destroy!)
        end
      end
    end
  end

  def act_type_names
    ['Initial Meeting', 'Pitch', 'Proposal', 'Feedback',
     'Agency Meeting', 'Client Meeting', 'Entertainment', 'Campaign Review',
     'QBR', 'Email', 'Post Sale Meeting', 'Internal Meeting']
  end
end
