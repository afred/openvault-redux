class UtilityController < ApplicationController
  def user_util_links
    render '/_user_util_links', :layout => false
  end
end
