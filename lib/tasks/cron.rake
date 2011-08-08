task :cron => :environment do
  Delayed::Job.enqueue(ScrapingJob.new())
end