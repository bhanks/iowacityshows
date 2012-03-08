
class EventsController < ApplicationController
  def index
    if(@venue)
      @events = @venue.events.order("events.begins_at ASC")
    else
      @events = Event.order("events.begins_at ASC")
    end
  end

  def show
    @event = Event.find(params[:id])
  end
  
  def today
    if(@venue)
      @events = @venue.events.today
    else
      @events = Event.today
    end
  end

  def week
    if(@venue)
      @events = @venue.events.week.order("events.begins_at ASC")
    else
      @events = Event.week.order("events.begins_at ASC")
    end
    render('index')
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
  end

  def update
    @event = Event.find(params[:id])
    p params.inspect
    #@event.prices.destroy_all
    if @event.update_attributes(params[:event])
      @event.save
      flash[:notice] = "Event updated successfully."
      redirect_to(:action => 'unconfirmed')
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
    Delayed::Job.enqueue(ScrapingJob.new())
    flash[:notice] = "Scrape initiated."
  end
  
  def unconfirmed
    if(@venue)
      @events = @venue.events.unconfirmed
    else
      @events = Event.unconfirmed
    end
  end
  
  def confirm
    @event = Event.find(params[:id])
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
