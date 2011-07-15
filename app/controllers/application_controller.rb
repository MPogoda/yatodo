class ApplicationController < ActionController::Base
  protect_from_forgery
  def render_404
    render :template => '404', :status => 404, :layout => true
  end
end
