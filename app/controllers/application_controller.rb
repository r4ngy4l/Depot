# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  layout "store"
  before_filter :authorize, :except => :login
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  # Scrub sensitive parameters from your log
  # filter_parameter_logging :password

  protected
  def authorize
    flash[:notice] = "Please create an admin user" if User.count == 0
    unless User.find_by_id(session[:user_id]) || User.count == 0
      session[:original_uri] = request.request_uri
      flash[:notice] = "Please log in"
      redirect_to :controller => 'admin' , :action => 'login'
    end
    if (User.count == 0 && request.path_parameters['action'] != "add_user")
      flash[:notice] = "Please create an account."
      redirect_to(:controller=>"login", :action=>"add_user")
    end
  end
end
