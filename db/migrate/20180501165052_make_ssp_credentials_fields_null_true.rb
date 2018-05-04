class MakeSspCredentialsFieldsNullTrue < ActiveRecord::Migration
  def change
    change_column_null :ssp_credentials, :key, true
    change_column_null :ssp_credentials, :secret, true
  end
end
