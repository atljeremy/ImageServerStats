class StaticsController < ApplicationController
  require 'gruff'

  def index
    AWS::S3::Base.establish_connection!(
        :access_key_id     => ENV['AWS_ACCESS_KEY_ID'],
        :secret_access_key => ENV['AWS_SECRET_ACCESS_KEY']
    )
    @photos = Photo.all
    @download_time_graph_url = get_chart_url_for_filename('download_times.png')
    @processing_time_graph_url = get_chart_url_for_filename('processing_times.png')
  end

  def map
    @photos = nil
    filter = params[:filter]

    if !filter.nil?
      case filter
        when '00-03'
          @photos = Photo.where('download_time <= 0.3')
        when '03-07'
          @photos = Photo.where('download_time > 0.3 AND download_time <= 0.7')
        when '07-10'
          @photos = Photo.where('download_time > 0.7 AND download_time < 1.0')
        when '10'
          @photos = Photo.where('download_time >= 1.0')
      end
    else
      @photos = Photo.all.order('download_time DESC')
    end

    if !@photos.nil?
      @photos.delete_if { |photo| photo.location_latitude.nil? || photo.location_longitude.nil? }
    else
      @photos = []
    end

    @hash = Gmaps4rails.build_markers(@photos) do |photo, marker|
      if photo.location_latitude && photo.location_longitude
        marker.lat photo.location_latitude
        marker.lng photo.location_longitude
        marker.infowindow "Photo URL: #{photo.server_url} <br/> Photo Download Time: #{photo.download_time}"
        marker.json({title: photo.download_time.round(2)})
      end
    end
  end

  private

  def get_chart_url_for_filename(filename)
    AWS::S3::S3Object.url_for(filename, ENV['AWS_BUCKET'], :authenticated => false)
  end

end
