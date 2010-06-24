# These helper methods can be called in your template to set variables to be used in the layout
# This module should be included in all views globally,
# to do so you may need to add this line to your ApplicationController
#   helper :layout
module LayoutHelper
  def title(page_title, show_title = true)
    @content_for_title = page_title.to_s
    @show_title = show_title
  end
  
  def show_title?
    @show_title
  end
  
  def stylesheet(*args)
    content_for(:head) { stylesheet_link_tag(*args) }
  end
  
  def javascript(*args)
    content_for(:head) { javascript_include_tag(*args) }
  end

  # Useful for Jammit
  def include_js_views(*args)
    args = ["#{controller_name}_#{action_name}"]  if args.blank?
    args.each do |arg|
      content_for(:js_views) { include_javascripts arg }
    end
  end
  alias :include_js_view :include_js_views

  # Useful for jQuery
  def show_flash_message (flash_action = flash.keys.first)
<<JAVASCRIPT
    $("div.flash").remove();
    var flash_message = $("<div id='flash-#{flash_action}' class='flash'>#{h(flash[flash_action.to_sym])}</div>");
    $("div#container div#content").prepend(flash_message);
JAVASCRIPT
  end
  
end
