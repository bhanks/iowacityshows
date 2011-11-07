require 'open-uri'
class Event < ActiveRecord::Base
  ActiveRecord::Base.inheritance_column = "activerecordtype" 
  
  belongs_to :venue
  has_many :prices, :dependent => :destroy
  accepts_nested_attributes_for :prices, :allow_destroy => true, :reject_if => lambda {|a| a[:amount].blank? }
  
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
  
  
  
  class GigPress
    def self.event_creator(item, venue)
      block=item
      scratch = Event.create!
      scratch.scraped_description = block.xpath('description').to_s
      info = Nokogiri::HTML(block.xpath('description').to_s)
      scratch.scraped_name = Event.xml_wrap(info, 'Artist')
      scratch.description = Event.xml_wrap(info, 'Notes')
      date = Event.xml_wrap(info, 'Date')
      time = Event.xml_wrap(info, 'Time')
      p date + time
      scratch.begins_at = DateTime.parse("#{date} #{time}")
      Event.price_helper(Event.xml_wrap(info, "Admission"),scratch.id )
      scratch.scraped_age = Event.xml_wrap(info, 'Age restrictions')
      scratch.marker = item.xpath('guid').text
      scratch.url = item.xpath('link').text
      scratch.venue_id = venue.id
      scratch.confirmed = 0
      permanent = Event.find_by_marker(scratch.marker)
      Event.comparison(scratch, permanent)

    end
  end

  class WordPress
    def self.event_creator(block)
      scratch = Event.create!
      scratch.url = scratch.marker = item.xpath('link')
      
    end
  end
  
  class YachtClub
    def self.event_creator(vevent, venue, url)
      scratch = Event.create!
      scratch.begins_at = DateTime.parse(vevent.css("h4").inner_html+" "+vevent.css("h2").inner_html)
      scratch.scraped_name = vevent.css("a").text
      scratch.description = vevent.css("p").inner_html
      price = vevent.css(".price").inner_html
      Event.price_helper(price, scratch.id)
      scratch.venue_id = venue.id
      scratch.confirmed = 0
      scratch.marker = [scratch.scraped_name, scratch.begins_at].join(";")
      scratch.url = url
      permanent = Event.find_by_marker(scratch.marker)
      Event.comparison(scratch,permanent)
    end
  end
  
  
  class Englert
    def self.event_creator(vevent, venue_id, url)
      scratch = Event.create!
      scratch.scraped_name = vevent.css("h1").inner_html.gsub(/<\/?[^>]*>/, "")
      price_text = vevent.css("font")[0].inner_html.to_s
      #Event.price_helper(price_text, scratch.id)
      scratch.description = (vevent.css("font")[1].nil?)? " " : vevent.css("font")[1].text.gsub(/<\/?[^>]*>/, "")
      scratch.scraped_age = "All Ages"
      scratch.venue_id = venue_id
      scratch.confirmed = 0
      scratch.marker = url
      scratch.url = "http://englert.org/#{url}"
      permanent = Event.find_by_marker(scratch.marker)
      Event.comparison(scratch, permanent)

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
