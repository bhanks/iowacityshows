class VenuesController < ApplicationController
  def index
    @venues = Venue.order("venues.name asc")
  end

  def show
    @venue = Venue.find(params[:id])
  end
  
  def new
    @venue = Venue.new
  end
  
  def create
    @venue = Venue.new(params[:venue])
    if @venue.save
      flash[:notice] = "Venue Created successfully."
      redirect_to(:action => 'index')
    else
      render('new')
    end
  end
    
  def edit
    @venue = Venue.find(params[:id])
  end
  
  def update
    @venue = Venue.find(params[:id])
    if @venue.update_attributes(params[:venue])
      flash[:notice] = "Venue updated successfully."
      redirect_to(:action=>'show', :id => @venue.id)
    else
      render('edit')
    end
  end
  
  def delete
    @venue = Venue.find(params[:id])
  end
  
  def destroy
    Venue.find(params[:id]).destroy
    flash[:notice] = "Venue destroyed successfully."
    redirect_to(:action => "index")
  end
  
end
