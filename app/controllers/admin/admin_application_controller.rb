class Admin::AdminApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_filter :is_admin_and_login
  include Admin::SessionsHelper

end