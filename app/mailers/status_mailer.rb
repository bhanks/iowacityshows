class StatusMailer < ActionMailer::Base
  default :from => "status@iowacityshows.com"

  def status_report
  	email = "ex.actionmodel@gmail.com"
  	log = File.open("log/scrape.log")
  	@report = log.read
  	mail(:to => email, :subject => "Status for scrape: #{Time.now.strftime("%m/%d/%y")}")
  end
end
