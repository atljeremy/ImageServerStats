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
      g.title = 'Overall Download Times'
      data1 = []
      data2 = []
      data3 = []
      data4 = []
      @photos.each { |photo|
        case photo.download_time
          when 0.0..0.3
            data1 << photo.download_time
          when 0.4..0.7
            data2 << photo.download_time
          when 0.7..1.0
            data3 << photo.download_time
          else
            data4 << photo.download_time
        end
      }
      g.data('0.0-0.3 Seconds', data1) if data1.size > 0
      g.data('0.4-0.7 Seconds', data2) if data2.size > 0
      g.data('0.7-1.0 Seconds', data3) if data3.size > 0
      g.data('1.0+ Seconds', data4) if data4.size > 0
      filename = 'overall_downloads.png'
      g.write(filename)
      path = Rails.root + filename
      File.open(path, 'rb') {|file|
        AWS::S3::S3Object.store(filename, file.read, ENV['AWS_BUCKET'], :access => :public_read)
      }
      @graph_url = AWS::S3::S3Object.url_for(filename, ENV['AWS_BUCKET'], :authenticated => false)
    end
  end

end
