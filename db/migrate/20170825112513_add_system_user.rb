class AddSystemUser < ActiveRecord::Migration
  def change
    User.create(
      id: 0,
      first_name: 'System',
      last_name: 'Change',
      email: 'system_change@email.com',
      password: 'password',
      confirmed_at: Time.now
    )
  end
end
