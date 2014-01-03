json.array!(@photos) do |photo|
  json.extract! photo, :id, :cacheHit, :downloadTime, :endTime, :responseHeaders, :serverURL, :size, :startTime
  json.url photo_url(photo, format: :json)
end
