class ScrapingJob < Struct.new(:venue)
  def perform
    Event.englert_events
    Event.mill_events
    Event.yacht_club_events
    Event.gabes_events
    Event.blue_moose_events
  end
end