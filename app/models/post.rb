require 'open-uri'
class Post < ActiveRecord::Base
  ActiveRecord::Base.inheritance_column = "activerecordtype" 
  
  belongs_to :venue
  has_many :events
  
  scope :examined, lambda {
    where("posts.state = 'examined'")
  }
  
  scope :received, lambda {
    where("posts.state = 'received'")
  }
  
  state_machine :state, :initial => :received do
    state :received
    state :examined
    state :altered
    
    after_transition :on => :examined, :do => :send_to_factory
    
    event :reexamine do
      transition :to => :examined, :from => [:altered]
    end
    
    event :alert do
      transition :to => :altered, :from => [:examined]
    end
    
    event :examine do
      transition :to => :examined, :from => [:received]
    end
  end
  
  def self.collect_posts
    venues = Venue.all
    venues.each {|venue|
      Post.const_get(venue.parse_type.to_sym).gather(venue)
    }
  end
  
  def send_to_factory
    Event.start_production(self.venue.parse_type.to_sym, self)
  end
  
  class RssBased
    def self.gather(venue)
      @posts = Post.gigpress_rss_scraper(venue)
    end
  end

  
  class YachtClub
    def self.gather(venue)
      @posts = []
      url = 'http://www.iowacityyachtclub.org/calendar.html'
    
      Nokogiri::HTML(open(url)).css(".entry").map do |vevent|
        scratch = Post.create!
        #These fields necessary to parse in order to create a sufficient marker
        begins_at = DateTime.parse(vevent.css("h4").inner_html+" "+vevent.css("h2").inner_html)
        scraped_name = vevent.css("a").text
        scratch.venue_id = venue.id
        scratch.block = vevent.inner_html
        scratch.marker = [scraped_name, begins_at].join(";")
        scratch.url = url
        permanent = venue.posts.find_by_marker(scratch.marker)
        @posts << Post.comparison(scratch, permanent)
      end
      @posts.reject!{|post| post.nil? }
      @posts
    end
    #End class YachtClub
  end
  
  class Englert
    def self.gather(venue)
      @posts = []
      
      Nokogiri::HTML(open('http://www.englert.org/events.php?view=upcoming')).css('#block_interior1').css("a").map do |node| 
        loc = node.attributes["href"].value
        vevent = Nokogiri::HTML(open('http://www.englert.org/'+loc)).css("#content_interior")
        @posts << Post.englert_post_parser(vevent, venue, loc)
      end

      Nokogiri::HTML(open('http://www.englert.org/events.php?view=upcoming')).css('#block_interior2').css("a").map do |node| 
        loc = node.attributes["href"].value
        vevent = Nokogiri::HTML(open('http://www.englert.org/'+loc)).css("#content_interior")
        @posts << Post.englert_post_parser(vevent, venue, loc)
      end
      @posts.reject!{|post| post.nil? }
      @posts
    end
    #End class Englert
  end
  
  class BlueMoose
    def self.gather(venue)
    end
  end
  
  def self.gigpress_rss_scraper(venue)
    url = venue.event_list_url
    feed = Nokogiri::XML(open(url))
    posts = []
    feed.xpath("//item").map do |item|
      scratch = self.create!
      scratch.block = item.inner_html
      scratch.marker = item.xpath('guid').text
      scratch.url = item.xpath('link').text
      scratch.venue_id = venue.id
      permanent = venue.posts.find_by_marker(scratch.marker)
      posts << Post.comparison(scratch, permanent)
    end
    posts.reject!{|post| post.nil? }
    posts
  end
  
  def self.englert_post_parser(vevent, venue, url)
    scratch = self.create!
    scratch.block = vevent.inner_html
    scratch.venue_id = venue.id
    scratch.marker = url
    scratch.url = "http://englert.org/#{url}"
    permanent = Post.find_by_marker(scratch.marker)
    
    Post.comparison(scratch, permanent)
  end
  
  def self.comparison(scratch, permanent)
    if(permanent.nil?)
      #If no event with this marker exists, go ahead and save everything.
      p "No post exists at marker #{scratch.marker}"
      scratch.save!
      post = scratch
    else
      if scratch.block != permanent.block
        p scratch.block
        # Mark related events unconfirmed; method not written yet
        p "New block differs from old block. #{scratch.venue.name}"
        permanent.alert
        permanent.save!
        post = permanent
      end
      scratch.destroy
    end
    post
  end
  
  #End class Post
end
