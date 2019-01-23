# frozen_string_literal: true

# ISK - A web controllable slideshow system
#
# Author::    Vesa-Pekka Palmu
# Copyright:: Copyright (c) 2012-2013 Vesa-Pekka Palmu
# License::   Licensed under GPL v3, see LICENSE.md

class ApplicationController < ActionController::Base
  # FIXME: currently we disable CSRF protection so that inkscape plugins
  # and displays can use the http api
  # protect_from_forgery

  # Require a logged in user by default for all actions
  before_action :require_login

  # Error to raise when user doesn't have the necessarry permissions
  class PermissionDenied < StandardError; end

  # Rescue from redirecting to back with no referer
  rescue_from ActionController::RedirectBackError, with: :return_to_root

  # Rescue from user having insufficient permissions for something
  rescue_from ApplicationController::PermissionDenied do |e|
    http_status_code(:forbidden, e)
  end

  def return_to_root
    redirect_to :root
  end

  # Memoize the current user
  def current_user
    # Bypass authentication in profile environment
    return @_current_user ||= User.first if Rails.env.profile?
    return @_current_user if @_current_user.present?
    return @_current_user = User.includes(:permissions).find_by_id(session[:user_id]) if session[:user_id]
    return nil unless params[:token]

    @_current_user = AuthToken.authenticate(params[:token])
    session[:user_id] = @_current_user.id
    return @_current_user
  end

  # Memoize the current event
  def current_event
    @_current_event ||= Event.current
  end

  # Append the current user to LogRage payload for logging
  def append_info_to_payload(payload)
    super
    payload[:user] = current_user
  end

private

  # Filter to use, requires that the user is admin
  def require_global_admin
    raise ApplicationController::PermissionDenied unless current_user.admin?
  end

  # Check if user has logged in and has certain role
  def require_role(r)
    return false unless current_user
    current_user.has_role?(r)
  end

  # This filter requires that a user has been logged in,
  # if not redirect to the login page
  def require_login
    return if current_user

    if request.get? && !request.xhr?
      session["login_return_to"] = request.fullpath
    end
    redirect_to login_path
  end

  # Require edit priviledges on obj, raises PermissionDenied if not permitted
  def require_edit(obj)
    return if obj.can_edit? current_user
    raise ApplicationController::PermissionDenied
  end

  # Render a predeterminated template for each http status code
  def http_status_code(status, exception = nil)
    # store the exception so its message can be used in the view
    @exception = exception

    # Only add the error page to the status code if the reuqest-format was HTML
    respond_to do |format|
      format.html { render template: "shared/status_#{status}", status: status }
      format.any  { head status } # only return the status code
    end
  end
end
