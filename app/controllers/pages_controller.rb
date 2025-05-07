class PagesController < ApplicationController
  def welcome
  end

  def set_name
    session[:creator_name] = params[:creator_name]
    redirect_to menu_path
  end

  def menu
    @name = session[:creator_name]
  end
end
