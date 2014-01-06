class AddConnectionStartedToPhoto < ActiveRecord::Migration
  def change
    add_column :photos, :connection_started, :datetime
  end
end
