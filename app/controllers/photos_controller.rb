class PhotosController < ApplicationController
  before_action :set_photo, only: [:show, :edit, :update, :destroy]
  skip_before_filter :verify_authenticity_token, only: [:add_photos]

  # GET /photos
  # GET /photos.json
  def index
    sort = params[:sort]
    order = 'processing_time DESC'
    if !sort.nil?
      order = "#{sort} DESC"
    end
    @photos = Photo.paginate :page => params[:page], :order => order
  end

  # GET /photos/1
  # GET /photos/1.json
  def show
  end

  # POST /photos/add.json
  def add_photos
    photos = params[:photos]
    photos_saved = 0
    photos.each { |photo|
      _photo = Photo.new
      _photo.cache_hit = photo[:cacheHit]
      _photo.download_time = photo[:downloadTime]
      _photo.end_time = photo[:endTime]
      _photo.start_time = photo[:startTime]
      _photo.server_url = photo[:serverURL]
      _photo.size = photo[:size]
      _photo.response_headers = photo[:responseHeaders]
      _photo.location_latitude = photo[:locationLatitude]
      _photo.location_longitude = photo[:locationLongitude]
      _photo.processing_time = photo[:processingTime]
      _photo.connection_started = photo[:connectionStarted]

      if _photo.save
        photos_saved += 1
      end
    }
    photos_received = photos.size
    json = {
        photos_received: photos_received,
        photos_saved: photos_saved,
        failed_to_save: (photos_received - photos_saved)
    }
    respond_to do |format|
      format.json { render json: json, status: :ok }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_photo
      @photo = Photo.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def photo_params
      params.require(:photo).permit(:cacheHit, :downloadTime, :endTime, :responseHeaders, :serverURL, :size, :startTime)
    end
end
