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
          @photos = Photo.where('download_time <= 0.3').order('location_latitude DESC')
        when '03-07'
          @photos = Photo.where('download_time > 0.3 AND download_time <= 0.7').order('location_latitude DESC')
        when '07-10'
          @photos = Photo.where('download_time > 0.7 AND download_time < 1.0').order('location_latitude DESC')
        when '10'
          @photos = Photo.where('download_time >= 1.0').order('location_latitude DESC')
      end
    else
      @photos = Photo.all.order('location_latitude DESC')
    end

    if !@photos.nil?
      @previous_photo
      @photos.delete_if { |photo|
        has_location_info = !photo.location_latitude.nil? && !photo.location_longitude.nil?
        same_location = false
        has_greater_download_time = false
        if has_location_info && !@previous_photo.nil?
          previous_has_location_info = !@previous_photo.location_latitude.nil? && !@previous_photo.location_longitude.nil?
          if previous_has_location_info
            same_lat = @previous_photo.location_latitude.round(0) == photo.location_latitude.round(0)
            same_long = @previous_photo.location_longitude.round(0) == photo.location_longitude.round(0)
            same_location = same_lat && same_long
            has_greater_download_time = @previous_photo.download_time < photo.download_time
          end
        end
        @previous_photo = photo
        (!has_location_info || same_location || (same_location && !has_greater_download_time))
      }
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
