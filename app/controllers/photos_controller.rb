class PhotosController < ApplicationController
  before_action :set_photo, only: [:show, :edit, :update, :destroy]
  skip_before_filter :verify_authenticity_token, only: [:add_photos]

  # GET /photos
  # GET /photos.json
  def index
    @photos = Photo.all
  end

  # GET /photos/1
  # GET /photos/1.json
  def show
  end

  # GET /photos/new
  def new
    @photo = Photo.new
  end

  # GET /photos/1/edit
  def edit
  end

  # POST /photos
  # POST /photos.json
  def create
    @photo = Photo.new(photo_params)

    respond_to do |format|
      if @photo.save
        format.html { redirect_to @photo, notice: 'Photo was successfully created.' }
        format.json { render action: 'show', status: :created, location: @photo }
      else
        format.html { render action: 'new' }
        format.json { render json: @photo.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /photos/1
  # PATCH/PUT /photos/1.json
  def update
    respond_to do |format|
      if @photo.update(photo_params)
        format.html { redirect_to @photo, notice: 'Photo was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @photo.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /photos/1
  # DELETE /photos/1.json
  def destroy
    @photo.destroy
    respond_to do |format|
      format.html { redirect_to photos_url }
      format.json { head :no_content }
    end
  end

  # POST /photos/add.json
  def add_photos
    photos = params[:photos]
    photos_saved = 0
    photos.each { |photo|
      _photo = Photo.new
      _photo.cacheHit = photo[:cacheHit]
      _photo.downloadTime = photo[:downloadTime]
      _photo.endTime = photo[:endTime]
      _photo.startTime = photo[:startTime]
      _photo.serverURL = photo[:serverURL]
      _photo.size = photo[:size]
      _photo.responseHeaders = photo[:responseHeaders]

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
