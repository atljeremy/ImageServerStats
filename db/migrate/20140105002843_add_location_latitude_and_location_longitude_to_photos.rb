class AddLocationLatitudeAndLocationLongitudeToPhotos < ActiveRecord::Migration
  def change
    add_column :photos, :location_latitude, :float
    add_column :photos, :location_longitude, :float
  end
end
