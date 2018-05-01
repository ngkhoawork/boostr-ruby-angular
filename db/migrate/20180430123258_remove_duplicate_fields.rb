class RemoveDuplicateFields < ActiveRecord::Migration
  def change
    Company.find_each do |company|
      dupes.each do |dupe|
        fields = company.fields.where(subject_type: 'Client', name: dupe, value_type: 'Option', locked: true).order(:created_at)

        if fields.count > 1
          fields.drop(1).map(&:really_destroy!)
        end
      end
    end
  end

  def dupes
    ['Member Role', 'Category', 'Region', 'Segment']
  end
end
