class RestaurantsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :find_from_params, :only => [:show, :rate, :edit, :update, :destroy]

  def index
    @restaurants = Restaurant.alphabetically
  end

  def show
  end

  def rate
    # update the rating
    @restaurant.rate(params[:stars], current_user, params[:dimension])
    # calculate new user figures
    user_rating_dom_id = @restaurant.wrapper_dom_id(params.merge(:show_user_rating => true, :current_user => current_user))
    p 'hi'
    user_rating        = @restaurant.rate_by(current_user, params[:dimension]).stars
    p [user_rating, current_user, params[:dimension]]
    user_width         = (user_rating / @restaurant.class.max_stars.to_f) * 100
    p 'hi'
    # calculate new global figures
    all_average        = @restaurant.rate_average(true, params[:dimension])
    all_width          = (all_average / @restaurant.class.max_stars.to_f) * 100
    all_rating_dom_id  = @restaurant.wrapper_dom_id(params.merge(:show_user_rating => false))
    p 'return_nh'
    return_hsh = {
      :id      => user_rating_dom_id, :average => user_rating, :width => user_width,
    }
    p ['new rating', return_hsh]
    render :json => return_hsh
  end

  def new
    @restaurant = Restaurant.new
  end

  def create
    @restaurant = Restaurant.new(params[:restaurant])
    if @restaurant.save
      flash[:notice] = "Successfully created restaurant."
      redirect_to @restaurant
    else
      render :action => 'new'
    end
  end

  def edit
  end

  def update
    if @restaurant.update_attributes(params[:restaurant])
      flash[:notice] = "Successfully updated restaurant."
      redirect_to restaurant_url
    else
      render :action => 'edit'
    end
  end

  def destroy
    @restaurant.destroy
    flash[:notice] = "Successfully destroyed restaurant."
    redirect_to restaurants_url
  end

private

  def find_from_params
    @restaurant = Restaurant.find(params[:id])
  end
end
