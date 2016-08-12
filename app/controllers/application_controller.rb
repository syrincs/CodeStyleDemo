# encoding: utf-8
class ApplicationController < ActionController::Base
  protect_from_forgery

  helper_method :current_user
  helper_method :current_ability
  helper_method :ajax_request?
  helper_method :proceed_location
  helper_method :order
  helper_method :admin?
  helper_method :manager?
  helper_method :employee?
  helper_method :staff?

  rescue_from CanCan::AccessDenied, with: :access_denied

  before_filter :cache_buster
  before_filter :set_default_locale
  before_filter :set_default_timezone
  before_filter :sign_in_user_from_autologin_secret
  before_filter :set_user_locale
  before_filter :set_user_timezone
  before_filter :set_request_variant

  # to work around https://github.com/ryanb/cancan/issues/835#issuecomment-18663815
  before_filter :cancan_resource_params_workaround

  layout :layout

  def bulk_operation
    operation = params[:operation]
    authorize!(operation.to_sym, resource_name.constantize)
    send(operation)
  end


  protected

  def default_url_options
    {
      locale: I18n.locale.to_s,
      autologin_secret: nil,
    }
  end

  def cache_buster
    headers['Cache-Control'] = 'no-store, no-cache, must-revalidate, post-check=0, pre-check=0'
    headers['Expires'] = 'Thu, 19 Nov 1981 08:52:00 GMT'
    headers['Pragma'] = 'no-cache'
  end

  def locale_from_accept_language_header
    request.env['HTTP_ACCEPT_LANGUAGE'] && request.env['HTTP_ACCEPT_LANGUAGE'].scan(/^[a-z]{2}/).first
  end

  def locale_from_params
    params_without_protection[:locale]
  end

  def set_default_locale
    locale = params[:locale] || locale_from_accept_language_header
    I18n.locale = I18n.available_locales.map(&:to_s).include?(locale) ? locale : I18n.default_locale
  end

  def set_default_timezone
    Time.zone = "Europe/Berlin"
  end

  def set_user_locale
    return unless current_user
    I18n.locale = current_user.locale
  end

  def set_user_timezone
    return unless current_user
    Time.zone = current_user.timezone
  end

  def access_denied(exception)
    return authenticate unless current_user
    redirect_to root_path, alert: _("Access denied!")
  end

  def authenticate
    return if current_user
    remember_location
    respond_to do |format|
      format.js{ render "require_login" }
      format.html{ redirect_to new_signup_path, alert: _("Please register or login first!") }
    end
  end

  def persistent
    session[:persistent] ||= {}
  end

  def proceed_location
    location = nil
    location = remembered_location if persistent[:remembered_location_ajax] == ajax_request?
    location ||= root_path
  end

  def remember_location
    persistent[:remembered_location] = request.url
    persistent[:remembered_location_ajax] = ajax_request?
  end

  def remembered_location
    persistent[:remembered_location]
  end

  def clear_remembered_location
    persistent.delete(:remembered_location)
  end

  def sign_in(user, log = true)
    sign_out
    session[:user_id] = user.id
    if log
      user.logins.create!(:status => "success", :ip => request.remote_ip)
    end
  end

  def sign_out
    persistent = {}
    [:persistent, :_csrf_token].each{ |k| persistent[k] = session[k] }
    session.clear
    [:persistent, :_csrf_token].each{ |k| session[k] = persistent[k] }
  end

  def find_autologin_object(allowed_klass = nil)
    return unless params[:autologin_secret]
    object_klass_uid, object_id, auth_token = params[:autologin_secret].split("-", 3)
    klass = {
      "u" => User,
    }[object_klass_uid]
    return if allowed_klass && klass != allowed_klass
    klass.find_by_id!(object_id).tap do |object|
      raise CanCan::AccessDenied unless object.auth_token == auth_token
    end
  end

  def sign_in_user_from_autologin_secret
    return if session[:user_id]
    user = find_autologin_object(User)
    sign_in(user) if user
  end

  def current_user
    return unless session[:user_id]
    @user_id ||= User.find_by_id(session[:user_id])
  end

  def current_ability
    @current_ability ||= Ability.new(current_user, request.format)
  end

  def manager?
    current_user && current_user.manager?
  end

  def admin?
    current_user && current_user.admin?
  end

  def employee?
    current_user && current_user.employee?
  end

  def staff?
    current_user && current_user.staff?
  end

  def ajax_request?
    [:js, :json].include?(request.format.try(:to_sym))
  end

  def layout
    ajax_request? ? false : "screen2015"
  end

  def order(default = 'id:desc')
    params[:order] ||= default
  end

  def resource_name
    controller_name.classify
  end

  def cancan_resource_params_workaround
    resource = resource_name.underscore
    method = "#{resource}_params"
    params[resource] &&= send(method) if respond_to?(method, true)
  end

  def set_request_variant
    request.variant = current_user ? [current_user.role.to_sym, :staff] : :guest
  end

  def return_or_redirect(default_path, options = {})
    path = case params[:return_to]
    when "outdated_offers"
      [:outdated, :offers]
    when "unapproved_offers"
      [:unapproved, :offers]
    when "deleted_offers"
      [:deleted, :offers]
    when "", nil
      default_path
    else
      params[:return_to]
    end
    redirect_to path, options
  end

  def determine_layout
    current_user && ["employee", "manager", "admin"].include?(current_user.role) ? "admin2015" : "screen2015"
  end
end
