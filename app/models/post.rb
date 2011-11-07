require 'open-uri'
class Post < ActiveRecord::Base
  ActiveRecord::Base.inheritance_column = "activerecordtype" 
  
  #  Post class:  Posts represent the state of Event data as it exists on the Venues' websites.
  #  A Post can have three states:
  #     -received: represents a post which has been been coarse-scraped.  Received posts haven't been examined by an admin.
  #     -examined: represents posts which have been examined for veracity and event count.  After a post is examined, the Post class
  #                should start the relevant Event factory to begin a coarse-scrape for the creation of one or many events.
  #     -altered: represents a post which has been previously examined, however some content on the related venue's site has been changed.
  #               Events related to altered posts need to be marked unconfirmed until such time as they have been examined again to ensure
  #               data veracity.
  
  
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
    
    after_transition :on => :examine, :do => :send_to_factory
    
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
      posts = Post.const_get(venue.parse_type.to_sym).gather(venue)
    }

  end
  
  
  class WordPress
    def self.gather(venue)

      url = venue.event_list_url
      feed = Nokogiri::XML(open(url))
      @posts = []
      feed.xpath("//item").map do |item|
        scratch = Post.create!
        scratch.block = item.xpath('description').text
        scratch.marker = scratch.url = item.xpath('link').text
        scratch.venue_id = venue.id
        permanent = venue.posts.find_by_marker(scratch.marker)
        Event::WordPress.event_creator(item)
        @posts << Post.comparison(scratch, permanent)
      end
      @posts.reject!{|post| post.nil? }
      @posts

    end
  end
  
  class GigPress
    def self.gather(venue)

      #@posts = Post.gigpress_rss_scraper(venue)
      url = venue.event_list_url
      feed = Nokogiri::XML(open(url))
      @posts = []
      feed.xpath("//item").map do |item|
        scratch = Post.create!
        scratch.block = item.text
        scratch.marker = item.xpath('guid').text
        scratch.url = item.xpath('link').text
        scratch.venue_id = venue.id
        Event::GigPress.event_creator(item, venue)
        permanent = venue.posts.find_by_marker(scratch.marker)
        @posts << Post.comparison(scratch, permanent)
      end
      @posts.reject!{|post| post.nil? }
      @posts

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
        Event::YachtClub.event_creator(vevent, venue, url)
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
        scratch = Post.create!
        scratch.block = vevent.css("#content_interior").text
        scratch.venue_id = venue.id
        scratch.marker = loc
        scratch.url = "http://englert.org/#{loc}"
        Event::Englert.event_creator(vevent, scratch.venue_id, scratch.url)
        permanent = Post.find_by_marker(scratch.marker)
        @posts << Post.comparison(scratch, permanent)
      end

      Nokogiri::HTML(open('http://www.englert.org/events.php?view=upcoming')).css('#block_interior2').css("a").map do |node| 
        loc = node.attributes["href"].value
        vevent = Nokogiri::HTML(open('http://www.englert.org/'+loc)).css("#content_interior")
        scratch = Post.create!
        scratch.block = vevent.css("#content_interior").text
        scratch.venue_id = venue.id
        scratch.marker = loc
        scratch.url = "http://englert.org/#{loc}"
        Event::Englert.event_creator(vevent, scratch.venue_id, scratch.url)
        permanent = Post.find_by_marker(scratch.marker)
        @posts << Post.comparison(scratch, permanent)
      end
      @posts.reject!{|post| post.nil? }
      @posts
    end
    #End class Englert
  end
  
  class TicketFly
    def self.gather(venue)
=begin
      @posts = []
      Nokogiri::XML(open(venue.event_list_url+"&maxResults=200")).xpath("map/entry[@key='events']/map").map do |node|
        scratch = Post.create!
        scratch.venue_id = venue.id
        scratch.block = node.xpath("entry[@key='lastUpdated']").text+"  "+node.xpath("entry[@key='name']").text
        scratch.marker = node.xpath("entry[@key='id']").text
        scratch.url = "http://www.ticketfly.com/api/events/upcoming.xml?eventId=#{scratch.marker}"
        permanent = Post.find_by_marker(scratch.marker)
        @posts << Post.comparison(scratch, permanent)
      end
      @posts.reject!{|post| post.nil? }
      @posts
=end
    end
  end
  

  
  def self.comparison(scratch, permanent)
    if(permanent.nil?)
      #If no event with this marker exists, go ahead and save everything.
      p "No post exists at marker #{scratch.marker}"
      scratch.save!
      post = scratch
    else
      if scratch.block != permanent.block
        # Mark related events unconfirmed; method not written yet
        p "New block differs from old block."
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
