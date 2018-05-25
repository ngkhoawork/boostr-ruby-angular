class CreateSpendAgreementTeamMembers < ActiveRecord::Migration
  def change
    create_table :spend_agreement_team_members do |t|
      t.references :user, index: true, foreign_key: true
      t.references :spend_agreement, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
