class AddLiveToDisplays < ActiveRecord::Migration
  def change
    add_column :displays, :live, :boolean, default: false
  end
end
