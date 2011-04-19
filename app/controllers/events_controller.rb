class EventsController < ApplicationController
  def index
    if(params[:venue_id])
      @events = Event.by_venue(params[:venue_id])
    else
      @events = Event.all
    end
  end

  def show
    @event = Event.find(params[:id])
  end
  
  def today
    if(params[:venue_id])
      @events = Event.by_venue(params[:venue_id]).today
    else
      @events = Event.today
    end
  end

  def week
    if(params[:venue_id])
      @events = Event.by_venue(params[:venue_id]).week.order("events.begins_at ASC")
    else
      @events = Event.week.order("events.begins_at ASC")
    end
  end
  
  def new
    @event = Event.new
  end
  
  def create
    @event = Event.create(params[:event])
    if (@event.venue_id.nil? and params[:venue_id])
      @event.venue_id = params[:venue_id]
    end
    @event.date = "#{params[:year]}-#{params[:month]}-#{params[:day]}".to_date
    if @event.save and @event.venue_id  
      flash[:notice] = "Event created successfully."
      redirect_to(:action => "index")
    else
      render('new')
    end
  end

  def edit
    @event = Event.find(params[:id])
    @date = Hash.new
    @date[:month], @date[:day], @date[:year] = @event.date.to_s.split("/")
  end

  def update
    @event = Event.find(params[:id])
    if @event.update_attributes(params[:event])
      @event.date = "#{params[:year]}-#{params[:month]}-#{params[:day]}".to_date
      @event.save
      flash[:notice] = "Event updated successfully."
      redirect_to(:action => 'index')
    else
      render('edit')
    end
  end

  def delete
    @event = Event.find(params[:id])
  end

  def destroy
    Event.find(params[:id]).destroy
    flash[:notice] = "Event successfully destroyed."
    redirect_to(:action => 'index')
  end
  
  def scrape
    @events = Event.mill_events
    @events += Event.gabes_events
    @events += Event.blue_moose_events
    @events += Event.yacht_club_events
  end
  
  
  before_filter :load_venues, :only => [:new, :edit]
  before_filter :find_venue
  protected
  def load_venues
    @venues_arr = Venue.all.map{|venue| [venue.name, venue.id] }
  end
  
  def find_venue
    if(params[:venue_id])
      @venue = Venue.find(params[:venue_id])
    end   
  end
  

end
