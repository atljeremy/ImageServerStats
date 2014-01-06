class AddProcessingTimeToPhoto < ActiveRecord::Migration
  def change
    add_column :photos, :processing_time, :float
  end
end
