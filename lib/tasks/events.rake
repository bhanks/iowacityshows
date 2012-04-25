namespace :events do
	desc "Scrape for events."
	task :collect => :environment do
		Event.collect_events
	end
end