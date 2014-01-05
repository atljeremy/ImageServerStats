class StaticsController < ApplicationController
  require 'gruff'

  def index
    AWS::S3::Base.establish_connection!(
        :access_key_id     => ENV['AWS_ACCESS_KEY_ID'],
        :secret_access_key => ENV['AWS_SECRET_ACCESS_KEY']
    )

    @photos = Photo.all.order('download_time DESC')

    if @photos.size > 0
      g = Gruff::Pie.new
      g.title = 'Overall Turnaround Times'
      g.theme = {
          :colors => [
              '#a9dada', # blue
              '#aedaa9', # green
              '#daaea9', # peach
              '#dadaa9', # yellow
              '#a9a9da', # dk purple
              '#daaeda', # purple
              '#dadada' # grey
          ],
          :marker_color => '#aea9a9', # Grey
          :font_color => 'black',
          :background_colors => '#f8f8f9'
      }

      value1 = 0
      value2 = 0
      value3 = 0
      value4 = 0
      @photos.each { |photo|
        case photo.download_time
          when 0.0..0.3
            value1 += 1
          when 0.4..0.7
            value2 += 1
          when 0.7..1.0
            value3 += 1
          else
            value4 += 1
        end
      }
      data1 = [value1]
      data2 = [value2]
      data3 = [value3]
      data4 = [value4]
      puts "Data 1 array count: #{data1.size}"
      puts "Data 2 array count: #{data2.size}"
      puts "Data 3 array count: #{data3.size}"
      puts "Data 4 array count: #{data4.size}"
      g.data('0.0-0.3 Seconds', (data1.size > 0) ? data1 : [0])
      g.data('0.4-0.7 Seconds', (data2.size > 0) ? data2 : [0])
      g.data('0.7-1.0 Seconds', (data3.size > 0) ? data3 : [0])
      g.data('1.0+ Seconds', (data4.size > 0) ? data4 : [0])

      filename = 'overall_downloads.png'
      g.write(filename)
      path = Rails.root + filename
      File.open(path, 'rb') {|file|
        AWS::S3::S3Object.store(filename, file.read, ENV['AWS_BUCKET'], :access => :public_read)
      }
      @graph_url = AWS::S3::S3Object.url_for(filename, ENV['AWS_BUCKET'], :authenticated => false)
    end
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
        when '10+'
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

end
