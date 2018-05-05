class AddWorkflowSignature < ActiveRecord::Migration
  def change
    add_column :workflows, :md5_signature, :string
  end
end
