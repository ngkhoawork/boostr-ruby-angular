class CreateSpendAgreementCustomFieldOptions < ActiveRecord::Migration
  def change
    create_table :spend_agreement_custom_field_options do |t|
      t.references :spend_agreement_custom_field_name, index: {
        name: 'index_spend_agreement_cf_options_on_spend_agreement_cf_name_id'
      }, foreign_key: true
      t.string :value

      t.timestamps null: false
    end
  end
end
