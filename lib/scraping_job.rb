class ScrapingJob < Struct.new(:venue)
  def perform
    if(:venue == "The Englert")
      Event.englert_events
    else
      Event.mill_events
      Event.yacht_club_events
      Event.gabes_events
      Event.blue_moose_events
    end
  end
end