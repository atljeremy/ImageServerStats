desc "This task is called by the Heroku scheduler add-on"
task :process_images => :environment do
  puts "Processing Images..."

  AWS::S3::Base.establish_connection!(
      :access_key_id     => ENV['AWS_ACCESS_KEY_ID'],
      :secret_access_key => ENV['AWS_SECRET_ACCESS_KEY']
  )
  Photo.create_pie_chart_for_processing_time
  Photo.create_pie_chart_for_download_time

  puts "Finished Processing Images."
end