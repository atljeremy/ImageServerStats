class CreatePhotos < ActiveRecord::Migration
  def change
    create_table :photos do |t|
      t.boolean :cacheHit
      t.float :downloadTime
      t.datetime :endTime
      t.text :responseHeaders
      t.string :serverURL
      t.integer :size
      t.datetime :startTime

      t.timestamps
    end
  end
end
