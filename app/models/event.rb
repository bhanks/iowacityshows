require 'open-uri'
class Event < ActiveRecord::Base
  belongs_to :venue
  has_many :prices, :dependent => :destroy
  accepts_nested_attributes_for :prices 
  
  scope :by_venue, lambda{ |venue_id|
    where("events.venue_id = ?", venue_id)
  }
  
  scope :today, lambda{
    where("events.begins_at >= ? and events.begins_at < ?", Date.today, Date.today+1 )
  }
  
  scope :week, lambda{
    where("events.begins_at >= ? and events.begins_at <= ? ", Date.today, Event.next_sunday+1 )
  }
  
  scope :past, lambda{
    where("events.begins_at < ?", Date.today.to_s(:db))
  }
  
  scope :unconfirmed, lambda{
    where("events.confirmed = ?", 0)
  }
  
  scope :confirmed, lambda{
    where("events.confirmed = ?", 1)
  }
  
  
  def self.mill_events
    venue = Venue.find_by_name("The Mill")
    venue.flush_events
    @events = Event.gigpress_rss_scraper(venue)
  end
  
  def self.gabes_events
    venue = Venue.find_by_name("Gabe's")
    venue.flush_events
    @events = Event.gigpress_rss_scraper(venue)
  end
  
  def self.blue_moose_events
    venue = Venue.find_by_name("Blue Moose Taphouse")
    venue.flush_events
    @events = Event.gigpress_rss_scraper(venue)
  end
  
  def self.gigpress_rss_scraper(venue)
    url = venue.event_list_url
    feed = Nokogiri::XML(open(url))
    events = []
    feed.xpath("//item").map do |item|
      scratch = self.create!
      #scratch.begins_at = DateTime.parse(item.xpath("pubDate").text)
      scratch.scraped_description = item.xpath('description').to_s
      info = Nokogiri::HTML(item.xpath('description').to_s)
      scratch.scraped_name = self.xml_wrap(info, 'Artist')
      scratch.description = self.xml_wrap(info, 'Notes')
      date = self.xml_wrap(info, 'Date')
      time = self.xml_wrap(info, 'Time')
      scratch.begins_at = DateTime.parse("#{date} #{time}")
      self.price_helper(self.xml_wrap(info, "Admission"),scratch.id )
      scratch.scraped_age = self.xml_wrap(info, 'Age restrictions')
      scratch.marker = item.xpath('guid').text
      scratch.url = item.xpath('link').text
      scratch.venue_id = venue.id
      scratch.confirmed = 0
      permanent = venue.events.find_by_marker(scratch.marker)
      if(permanent.nil?)
         #If no event with this marker exists, go ahead and save everything.
         p "Saving scratch"
         scratch.save!
         events << scratch
       else
         
         if (scratch.scraped_description != permanent.scraped_description)
           permanent.confirmed = 0
           permanent.save!
           p "Unconfirming Permanent."
           events << permanent
         end
         scratch.destroy
       end
      
    end
    events
  end
  
  
  def self.yacht_club_events
    venue = Venue.find_by_name("The Yacht Club")
    venue.flush_events
    @events = []
    url = 'http://www.iowacityyachtclub.org/calendar.html'
    
    Nokogiri::HTML(open(url)).css(".entry").map do |vevent|
      scratch = self.create!
      scratch.begins_at = DateTime.parse(vevent.css("h4").inner_html+" "+vevent.css("h2").inner_html)
      scratch.scraped_name = vevent.css("a").text
      scratch.description = vevent.css("p").inner_html
      price = vevent.css(".price").inner_html
      self.price_helper(price, scratch.id)
      scratch.venue_id = venue.id
      scratch.confirmed = 0
      scratch.marker = [scratch.scraped_name, scratch.begins_at].join(";")
      scratch.url = url
      permanent = Event.find_by_marker(scratch.marker)
      if(permanent.nil?)
        #If no event with this marker exists, go ahead and save everything.
        scratch.save
        @events << scratch
      else
        unless [:scraped_name, :begins_at].all? {|a| scratch.send(a) == permanent.send(a)}
          permanent.confirmed = 0
          permanent.save
          @events << permanent
        end
        scratch.destroy
      end
    end
    @events
  end
  
  def self.englert_events
    venue_id = Venue.find_by_name("The Englert").id
    Event.flush_events(venue_id)
    @events = []
    Nokogiri::HTML(open('http://www.englert.org/events.php?view=upcoming')).css('#block_interior1').css("a").map do |node| 
      loc = node.attributes["href"].value
      vevent = Nokogiri::HTML(open('http://www.englert.org/'+loc)).css("#content_interior")
      @events << Event.englert_event_parser(vevent, venue_id,loc)
    end

    Nokogiri::HTML(open('http://www.englert.org/events.php?view=upcoming')).css('#block_interior2').css("a").map do |node| 
      loc = node.attributes["href"].value
      vevent = Nokogiri::HTML(open('http://www.englert.org/'+loc)).css("#content_interior")
      @events << Event.englert_event_parser(vevent, venue_id,loc)
    end

    @events
  end
  
  
  def self.englert_event_parser(vevent, venue_id, url)
    scratch = self.create!
    scratch.scraped_name = vevent.css("h1").inner_html.gsub(/<\/?[^>]*>/, "")
    price_text = vevent.css("font")[0].inner_html.to_s
    self.price_helper(price_text, scratch.id)
    scratch.description = (vevent.css("font")[1].nil?)? " " : vevent.css("font")[1].text.gsub(/<\/?[^>]*>/, "")
    scratch.scraped_age = "All Ages"
    scratch.venue_id = venue_id
    scratch.confirmed = 0
    scratch.marker = url
    scratch.url = "http://englert.org/#{url}"
    permanent = Event.find_by_marker(scratch.marker)
    if(permanent.nil?)
      #If no event with this marker exists, go ahead and save everything.
      scratch.save
      event = scratch
    else
      unless [:scraped_name].all? {|a| scratch.send(a) == permanent.send(a)}
        permanent.confirmed = 0
        permanent.save
        event = permanent
      end
      scratch.destroy
    end
    event
  end
    
  
  def self.next_sunday
    unless(Date.today.cwday == 7)
      days = (0..6).map{|x| Date.today + x}
      sunday = days.select{|day| day.cwday == 7}.first
    else
      sunday = Date.today
    end
    sunday
  end
  
  def self.price_helper(price_text, event_id)
    
    price = price_text.scan(/\$(\d+)/).flatten
    if(price.empty?)
      price = price_text.scan(/(Free|FREE)/).flatten
    end
    prices = []
    price.each do |p|
      p "Creating price #{p} for Event #{event_id}"
      prices << Price.create!(:amount=>p,:event_id=>event_id)
    end
    prices
  end

  #Helper method for gigpress feeds
  def self.xml_wrap(item, text)
    wrapper = item.xpath(".//li/strong[text()='#{text}:']/..")
    wrapper.xpath(".//strong[text()='#{text}:']").remove
    wrapper.text.strip
  end
  
  def name
    self[:name] ||= self[:scraped_name]
  end
      
end
