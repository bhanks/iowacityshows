require 'fileutils'
namespace :events do
	desc "Scrape for events."
	task :collect => :environment do
		startTime = Time.now

		begin
			Event.collect_events
		rescue Exception => msg
			failure = true
			puts "Scrape failed: #{msg}"
		end
		endTIme = Time.now
		puts "Total time: #{endTIme-startTime} seconds." 
		unless failure
			Venue.all.each{|v|
				puts "#{v.name}: #{v.events.fresh.count} fresh, #{v.events.changed.count} updated, #{v.events.all_upcoming.count} total events upcoming."
			}
		end
	end

	task :status => :environment do
		log = File.open("log/scrape.log")
		status = log.read
		puts status
	end
end