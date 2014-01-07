class Photo < ActiveRecord::Base

  def self.create_pie_chart_for_download_time
    @photos = all.order('download_time DESC')

    if @photos.size > 0
      g = Gruff::Pie.new
      g.title = 'Image Download Times'
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
      g.data('0.0-0.3 Seconds', (data1.size > 0) ? data1 : [0])
      g.data('0.4-0.7 Seconds', (data2.size > 0) ? data2 : [0])
      g.data('0.7-1.0 Seconds', (data3.size > 0) ? data3 : [0])
      g.data('1.0+ Seconds', (data4.size > 0) ? data4 : [0])

      filename = 'download_times.png'
      g.write(filename)
      path = Rails.root + filename
      File.open(path, 'rb') {|file|
        AWS::S3::S3Object.store(filename, file.read, ENV['AWS_BUCKET'], :access => :public_read)
      }
    end
  end

  def self.create_pie_chart_for_processing_time
    @photos = all.order('processing_time DESC')

    if @photos.size > 0
      g = Gruff::Pie.new
      g.title = 'Server Processing Times'
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
        case photo.processing_time
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
      g.data('0.0-0.3 Seconds', (data1.size > 0) ? data1 : [0])
      g.data('0.4-0.7 Seconds', (data2.size > 0) ? data2 : [0])
      g.data('0.7-1.0 Seconds', (data3.size > 0) ? data3 : [0])
      g.data('1.0+ Seconds', (data4.size > 0) ? data4 : [0])

      filename = 'processing_times.png'
      g.write(filename)
      path = Rails.root + filename
      File.open(path, 'rb') {|file|
        AWS::S3::S3Object.store(filename, file.read, ENV['AWS_BUCKET'], :access => :public_read)
      }
    end
  end

end
