class MoviesController < ApplicationController

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
    redirect = 0
    @all_ratings = ['G','PG','PG-13','R']

    if session[:ratings].present? && params[:ratings].nil?
      params[:ratings] = session[:ratings]
      session.delete(:ratings)
      redirect = 1      
    end

    if session[:sort_by].present? && params[:sort_by].nil?
      params[:sort_by] = session[:sort_by]
      session.delete(:sort_by)
      redirect = 1      
    end
    
    if redirect == 1
      flash.keep
      redirect_to movies_path(:ratings => params[:ratings], :sort_by => params[:sort_by])    
    end
    
    rating_filter = params[:ratings] ? params[:ratings].keys : @all_ratings
    if params[:sort_by]
      @movies = Movie.order(params[:sort_by]).where('rating IN (?)', rating_filter)
      @title_class = "hilite" if params[:sort_by] == "title"
      @release_date_class = "hilite" if params[:sort_by] == "release_date"
    else
      @movies = Movie.where('rating IN (?)', rating_filter)
      @title_class = "non_hilite"
      @release_date_class = "non_hilite"
    end
    @all_ratings.each {|rating| rating_filter.include?(rating) ? flash[rating]= true : flash[rating]= false}
    session[:ratings] = params[:ratings] if params[:ratings]
    session[:sort_by] = params[:sort_by] if params[:sort_by] 
  end

  def new
    # default: render 'new' template
  end

  def create
    @movie = Movie.create!(params[:movie])
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(params[:movie])
    flash[:notice] = "#{@movie.title} was successfully updated."
    redirect_to movie_path(@movie)
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end

end
