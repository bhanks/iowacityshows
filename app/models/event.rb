require 'open-uri'
class Event < ActiveRecord::Base
  belongs_to :venue
  scope :by_venue, lambda{ |venue_id|
    where("events.venue_id = ?", venue_id)
  }
  
  scope :today, lambda{
    where("events.begins_at >= ? and events.begins_at < ?", Date.today, (Date.today+1))
  }
  
  scope :through, lambda{ |end_date|
    where("events.date >= ? and events.date <= ?", Date.today, end_date )
  }
  
  
  def self.mill_events
    venue_id = Venue.find_by_name("The Mill").id
    Event.flush_events(venue_id)
    @events = []
    Nokogiri::HTML(open('http://icmill.com/?page_id=5')).css("#posts .vevent").map do |vevent|
     event = Event.new
     event.begins_at = DateTime.parse(vevent.css(".dtstart").at("./@title").to_s)
     event.name = vevent.css(".gigpress-artist").at("./text()").to_s.strip
     event.description = vevent.css(".description .gigpress-info-item").first.inner_html
     event.price = vevent.at(".//span[@class='gigpress-info-item' and contains(span, 'Admission')]/text()").to_s.strip
     event.age_restriction = vevent.at(".//span[@class='gigpress-info-item' and contains(span, 'Age restrictions')]/text()").to_s.strip
     event.venue_id = venue_id
     event.save
     @events << event
    end
    @events
  end
  
  def self.gabes_events
    venue_id = Venue.find_by_name("Gabe's").id
    Event.flush_events(venue_id)
    @events = []
    Nokogiri::HTML(open('http://www.iowacitygabes.com/calendar/')).css("tbody.vevent").map do |vevent|
      event = self.new
      event.begins_at = DateTime.parse(vevent.css(".dtstart").at("./@title").to_s)
      event.name = vevent.css(".gigpress-artist").at("./text()").to_s.strip
      event.description = vevent.at(".//span[@class='gigpress-info-item' and not(span)]/text()").to_s.strip
      event.price = vevent.at(".//span[@class='gigpress-info-item' and contains(span, 'Admission')]/text()").to_s.strip
      event.age_restriction = vevent.at(".//span[@class='gigpress-info-item' and contains(span, 'Age restrictions')]/text()").to_s.strip
      event.venue_id = venue_id
      event.save
      @events << event
    end
    @events
  end
  
  def self.blue_moose_events
    venue_id = Venue.find_by_name("Blue Moose Taphouse").id
    Event.flush_events(venue_id)
    @events = []
    Nokogiri::HTML(open('http://bluemooseic.com/events/')).css("tbody.vevent").map do |vevent|
      event = self.new
      event.begins_at = DateTime.parse(vevent.css(".dtstart").at("./@title").to_s)
      event.name = vevent.css(".gigpress-artist").at("./text()").to_s.strip
      event.description = vevent.css(".gigpress-info-notes").inner_html
      event.price = vevent.at(".//span[@class='gigpress-info-item' and contains(span, 'Admission')]/text()").to_s.strip
      event.age_restriction = vevent.at(".//span[@class='gigpress-info-item' and contains(span, 'Age restrictions')]/text()").to_s.strip
      event.venue_id = venue_id
      event.save
      @events << event
    end
    @events
  end
  
  def self.yacht_club_events
    venue_id = Venue.find_by_name("The Yacht Club").id
    Event.flush_events(venue_id)
    @events = []
    Nokogiri::HTML(open('http://www.iowacityyachtclub.org/calendar.html')).css(".entry").map do |vevent|
      event = self.new
      event.begins_at = DateTime.parse(vevent.css("h4").inner_html+" "+vevent.css("h2").inner_html)
      event.name = vevent.css("a").inner_html
      event.description = vevent.css("p").inner_html
      event.price = vevent.css(".price").inner_html # .match(/$(\d+)/)[1]
      event.venue_id = venue_id
      event.save
      @events << event
    end
    @events
  end
  
  def self.flush_events(venue_id)
    events = Event.by_venue(venue_id)
    events.delete_all
  end
  
end
