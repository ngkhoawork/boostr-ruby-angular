class UpdateFreezedForIos < ActiveRecord::Migration
  def change
    Io.all.update_all(freezed: true)
  end
end
