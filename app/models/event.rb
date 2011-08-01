require 'open-uri'
class Event < ActiveRecord::Base
  belongs_to :venue
  scope :by_venue, lambda{ |venue_id|
    where("events.venue_id = ?", venue_id)
  }
  
  scope :today, lambda{
    where("events.begins_at >= ? and events.begins_at < ?", Date.today, Date.today+1 )
  }
  
  scope :week, lambda{
    where("events.begins_at >= ? and events.begins_at <= ?", Date.today, Event.next_sunday+1 )
  }
  
  
  def self.mill_events
    venue_id = Venue.find_by_name("The Mill").id
    Event.flush_events(venue_id)
    @events = []
    Nokogiri::HTML(open('http://icmill.com/?page_id=5')).css("#posts .vevent").map do |vevent|
     event = Event.new
     event.begins_at = DateTime.parse(vevent.css(".dtstart").at("./@title").to_s)
     event.name = vevent.css(".gigpress-artist").at("./text()").to_s.strip
     event.description = vevent.css(".description .gigpress-info-item").first.inner_html.gsub(/<br>/,".").gsub(/<\/?[^>]*>/, "")
     price_text = vevent.at(".//span[@class='gigpress-info-item' and contains(span, 'Admission')]/text()").to_s.strip
     event.price = self.price_helper(price_text)
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
      price_text = vevent.at(".//span[@class='gigpress-info-item' and contains(span, 'Admission')]/text()").to_s.strip
      event.price = self.price_helper(price_text)
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
      #Prices stored as a single string in this format: [price],[price],...
      price_text = vevent.at(".//span[@class='gigpress-info-item' and contains(span, 'Admission')]/text()").to_s.strip
      event.price = self.price_helper(price_text)
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
      if event.begins_at.hour < 22
        event.age_restriction = "19+"
      elsif event.begins_at.hour >= 22
        event.age_restriction = "21+"
      end
      event.name = vevent.css("a").inner_html
      event.description = vevent.css("p").inner_html
      price = vevent.css(".price").inner_html
      event.price = self.price_helper(price)
      event.venue_id = venue_id
      event.save
      @events << event
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
      reported_time = vevent.css(".event_name").text
      if(reported_time.split(",")[0].split("-").length == 1)
        start_time = DateTime.parse(vevent.css(".event_name").text)
        #p start_time
        @events << Event.englert_event_parser(vevent, venue_id,start_time)
      else
        #process multiple day events here
        start_day = reported_time.split(",")[0].split("-")[0]
        end_day = reported_time.split(",")[0].split("-")[1]
          #p start_day
          #p end_day
      end
    end

    Nokogiri::HTML(open('http://www.englert.org/events.php?view=upcoming')).css('#block_interior2').css("a").map do |node| 
      loc = node.attributes["href"].value
      vevent = Nokogiri::HTML(open('http://www.englert.org/'+loc)).css("#content_interior")
      reported_time = vevent.css(".event_name").text
      #p reported_time
      if(reported_time.split(",")[0].split("-").length == 1)
        start_time = DateTime.parse(vevent.css(".event_name").text)
        #p start_time
        @events << Event.englert_event_parser(vevent, venue_id,start_time)
      else
        #process multiple day events here
        month = reported_time.split(",")[1].split("-")[0].split(" ")[0]
        start_day = DateTime.parse(reported_time.split(",")[0].split("-")[0].strip+", "+reported_time.split(",")[1].split("-")[0]+", "+reported_time.split(",")[2].split("-")[0])
        end_day = DateTime.parse(reported_time.split(",")[0].split("-")[1].strip+", #{month} "+reported_time.split(",")[1].split("-")[1]+", "+reported_time.split(",")[2].split("-")[0])
        p start_day
        p end_day
      end
    end

    @events.each{|event| event.save}
    @events
  end
  
  
  def self.englert_event_parser(vevent, venue_id, date)
    event = self.new
    event.name = vevent.css("h1").inner_html
    #event.begins_at = DateTime.parse(vevent.css(".event_name").text)
    event.begins_at = date
    price_text = vevent.css("font")[0].inner_html.to_s
    event.price = self.price_helper(price_text)
    event.description = (vevent.css("font")[1].nil?)? " " : vevent.css("font")[1].text.gsub(/<\/?[^>]*>/, "")
    event.age_restriction = "All Ages"
    event.venue_id = venue_id
    event
  end
    
  
  def self.flush_events(venue_id)
    events = Event.by_venue(venue_id)
    events.delete_all
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
  
  def self.price_helper(price_text)
    
    price = price_text.scan(/\$(\d+)/).flatten
    if(price.empty?)
      price = price_text.scan(/(Free|FREE)/).flatten
    end
    price = price.join(",")
    price
  end
  
  def price_render()
    price_arr = self.price.split(",")
    unless(price_arr.first.nil?)
		  if( price_arr.first.casecmp("free") == 0)
  			price = self.price
  		else
  			price = price_arr.map{|a| a.insert(0,'$')}.join("/")
  		end
  	else
  	  price = ''
  	end
		price
  end
  
  def description_render()
    desc_string = self.description
    if(self.description.length >= 120 )
      desc_string = ""
      self.description.scan(/\s\w*\s|\w*\s|\w*[.!]|\w*\W\w*/){ |w| 
        break if desc_string.length > 120
        desc_string << "#{w}"
      }
      desc_string << "..."
    end
    desc_string
      
  end
  
end
