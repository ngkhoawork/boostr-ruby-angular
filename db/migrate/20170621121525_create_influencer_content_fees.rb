class CreateInfluencerContentFees < ActiveRecord::Migration
  def change
    create_table :influencer_content_fees do |t|
      t.belongs_to :influencer, index: true, foreign_key: true
      t.belongs_to :content_fee, index: true, foreign_key: true
      t.string :fee_type
      t.string :curr_cd
      t.decimal :gross_amount, precision: 15, scale: 2
      t.decimal :gross_amount_loc, precision: 15, scale: 2
      t.decimal :net, precision: 15, scale: 2
      t.text :asset

      t.timestamps null: false
    end
  end
end
