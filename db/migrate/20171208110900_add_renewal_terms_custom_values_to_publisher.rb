class AddRenewalTermsCustomValuesToPublisher < ActiveRecord::Migration
  def change
    Company.all.find_each do |company|
      company.fields.find_or_create_by(
        subject_type: 'Publisher',
        name: 'Renewal Terms',
        value_type: 'Option',
        locked: true
      )
    end
  end
end
