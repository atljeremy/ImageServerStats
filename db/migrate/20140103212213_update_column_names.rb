class UpdateColumnNames < ActiveRecord::Migration
  def change
    rename_column :photos, :cacheHit, :cache_hit
    rename_column :photos, :downloadTime, :download_time
    rename_column :photos, :startTime, :start_time
    rename_column :photos, :endTime, :end_time
    rename_column :photos, :serverURL, :server_url
    rename_column :photos, :responseHeaders, :response_headers
  end
end
