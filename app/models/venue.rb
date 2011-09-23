class Venue < ActiveRecord::Base
  has_many :posts 
  has_many :events, :through => :posts
  
  def flush_events
    self.events.past.destroy_all
  end
  

  
end
