require 'open-uri'
class Event < ActiveRecord::Base
  ActiveRecord::Base.inheritance_column = "activerecordtype" 
  
  belongs_to :venue
  
  scope :by_venue, lambda{ |venue_id|
    where("events.venue_id = ?", venue_id)
  }
  
  scope :today, lambda{
    where("events.begins_at >= ? and events.begins_at < ?", Date.today, Date.today+1 )
  }
  
  scope :week, lambda{
    where("events.begins_at >= ? and events.begins_at <= ? ", Date.today, Date.today+7 )
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
  
  def self.collect_events
    p 'Lets get scrapin!'
    venues = Venue.all
    venues.each {|venue|
      posts = Event.const_get(venue.parse_type.to_sym).gather(venue)
    }

  end
  
  class GigPress
    def self.gather(venue)
      @events = []
      Nokogiri::XML(open(venue.event_list_url)).xpath("//item").map do |item|
        scratch = Event.create!

        scratch.name =  item.xpath("title").text
        scratch.description = Event.xml_wrap(item, 'Notes')
        date = Event.xml_wrap(item, 'Date')
        time = Event.xml_wrap(item, 'Time')
        scratch.begins_at = DateTime.parse("#{date} #{time}")
        scratch.price = Event.xml_wrap(item, 'Admission')
        scratch.age_restriction = Event.xml_wrap(item, 'Age restrictions')
        scratch.marker = item.xpath('guid').text
        scratch.url = item.xpath('link').text
        scratch.venue_id = venue.id
        permanent = Event.find_by_marker(scratch.marker)
        @events << Event.comparison(scratch, permanent)
      end
      @events.reject!{|event| event.nil? }
      @events
    end
  end

  class Midwestix
    def self.gather(venue)
      #go to the page with all the goddamn links we have to follow
      index = Nokogiri::HTML(open(venue.event_list_url))
      p "opened event list"
      @events = []
      index.xpath("//a[text()='buy tickets']").map do |node| 
        item = Nokogiri::HTML(open("#{node.attributes['href'].text}"))
        scratch = Event.create!
        scratch.venue_id = venue.id
        scratch.name = item.xpath("//div[@class='EventInfoItemEventName ItemName']").text
        scratch.description = ""
        unless item.xpath("//div[@class='EventInfoItemSupportingText']").text == ""
          scratch.description += item.xpath("//div[@class='EventInfoItemSupportingText']").text+" : "
        end
        scratch.description += item.xpath("//div[@class='EventInfoShortDescription']").text
        scratch.begins_at = DateTime.parse(item.xpath("//div[@class='EventInfoItemDateTime']").text)
        scratch.description += "\n"+item.xpath("//div[@class='EventInfoDateTimeSecondaryText']").text
        scratch.price = ""
        scratch.age_restriction = ""
        scratch.url = "http://events.midwestix.com/#{node.attributes['href'].text}"
        scratch.marker = node.attributes['href'].text
        permanent = Event.find_by_marker(scratch.marker)
        @events << Event.comparison(scratch, permanent)
      end
      @events.reject!{|event| event.nil? }
      @events
    end
  end

  class TicketFly
    def self.gather(venue)

      @events = []
      Nokogiri::XML(open(venue.event_list_url+"&maxResults=200")).xpath("map/entry[@key='events']/map").map do |node|
        scratch = Event.create!
        scratch.venue_id = venue.id
        scratch.marker = node.xpath("entry[@key='id']").text
        scratch.name = node.xpath("entry[@key='name']").text
        scratch.description = node.xpath("entry[@key='headliners']/map/entry[@key='eventDescription']").text
        scratch.age_restriction = node.xpath("entry[@key='ageLimit']").text
        scratch.begins_at = DateTime.parse(node.xpath("entry[@key='startDate']").text)
        scratch.price = node.xpath("entry[@key='ticketPrice']").text
        scratch.url = "http://www.ticketfly.com/event/#{scratch.marker}"
        permanent = Event.find_by_marker(scratch.marker)
        @events << Event.comparison(scratch, permanent)
      end
      @events.reject!{|event| event.nil? }
      @events

    end
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
=begin  
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
=end
  def self.price_helper(price)
    if price.scan(/\$(\d+)/).flatten.length != 0
      s = price.scan(/\$(\d+)/).flatten.map{|y| "$"+y}.join("-")
    else
      s = price
    end
    s
  end

  def self.age_helper(age)
    if age.scan(/(19|21)/).flatten.length != 0
      s = age.scan(/(19|21)/).flatten[0]+"+"
    else
      s = age
    end
    s
  end

  #Helper method for gigpress feeds
  def self.xml_wrap(item, text)
    #might be multiple cdata nodes in description node
    cdata = Nokogiri::XML(item.xpath("description").children.first.text)
    #cdata.xpath(".//li/strong[text()='Time:']/..").children[1].text
    wrapper = cdata.xpath(".//li/strong[text()='#{text}:']/..")
    wrapper.xpath(".//strong[text()='#{text}:']").remove
    wrapper.text.strip
  end
  
  def name
    self[:name] ||= self[:scraped_name]
  end
  
  def self.comparison(scratch, permanent)
    if(permanent.nil?)
      #If no event with this marker exists, go ahead and save everything.
      p "No event exists at marker #{scratch.marker}"
      scratch.save!
    else
      scratch.destroy
    end
  end
  
      
end
