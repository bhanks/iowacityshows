class Venue < ActiveRecord::Base
  has_many :events
  
  def flush_events
    self.events.past.destroy_all
  end
end
