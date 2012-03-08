class ScrapingJob < Struct.new(:venue)
  def perform
 	Event.collect_events
  end
end