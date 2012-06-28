class StatusMailer < ActionMailer::Base
  default :from => "ics.scraper@gmail.com"

  def status_report(tme)
  	email = "ex.actionmodel@gmail.com"
  	@tme = tme
  	@report = []
  	Struct.new("Report",:v_name, :fresh, :changed, :upcoming)
  	Venue.all.each{|v|
  		fresh = v.events.fresh.count
  		changed = v.events.changed.count
  		upcoming = v.events.all_upcoming.count
  		r = Struct::Report.new(v.name, fresh, changed, upcoming)
  		@report << r
  	}
  	mail(:to => email, :subject => "Status for scrape: #{Time.now.strftime("%m/%d/%y")}")
  end
end
