require 'fileutils'
namespace :events do
	desc "Scrape for events."
	task :collect => :environment do
		startTime = Time.now
		FileUtils.mv("log/scrape.log", "log/scrape.last")
		Rails.logger = Logger.new("log/scrape.log")
		
		Rails.logger.info "Starting scrape at #{Time.now}"
		begin
			Event.collect_events
		rescue Exception => msg
			failure = true
			puts "Scrape failed: #{msg}"
			Rails.logger.info "Scrape failed: #{msg}"
		end
		endTIme = Time.now
		puts "Total time: #{endTIme-startTime} seconds." 
		unless failure
			Rails.logger.info "Scrape completed successfully in #{endTIme-startTime} seconds."
		end
	end

	task :status => :environment do
		log = File.open("log/scrape.log")
		status = log.read
		puts status
	end
end