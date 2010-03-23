// Based on :
// http://blog.lawrencepit.com/2008/09/04/unobtrusive-jquery-rails
// http://railscasts.com/episodes/136-jquery
// http://brandonaaron.net/blog/2009/02/25/unobtrusive-destroy-links-in-rails-using-jquery

// Behaviours
$(document).ready(function()
{
  // All non-GET requests will add the authenticity token
  // if not already present in the data packet
  $("body").bind("ajaxSend", function(elm, xhr, s)
  {
    if (s.type == "GET")
      return;

    if (s.data && s.data.match(new RegExp("\\b" + window._auth_token_name + "=")))
      return;

    if (s.data)
      s.data = s.data + "&";
    else 
    {
      s.data = "";
      // if there was no data, jQuery didn't set the content-type
      xhr.setRequestHeader("Content-Type", s.contentType);
    }
    s.data = s.data + encodeURIComponent(window._auth_token_name) + "=" + encodeURIComponent(window._auth_token);
  });
});

// All ajax requests will trigger the wants.js block
// of +respond_to do |wants|+ declarations
jQuery.ajaxSetup({
  'beforeSend': function(xhr) {xhr.setRequestHeader("Accept", "text/javascript")}
});

jQuery.fn.submitWithAjax = function() {
  //jQuery 1.3.x .live() function doesn't support theses events : blur, focus, mouseenter, mouseleave, change and submit
  //So we need to use jquery.livequery plugin
  this.livequery('submit',function(e)
  {
    $.post(this.action, $(this).serialize(), null, "script");
    e.preventDefault();
  });
  return this;
};

// More behaviours
$(document).ready(function() {
  // All A tags with class 'remote-get', 'remote-post', 'remote-put' or 'remote-delete' will perform an ajax call
  $('a.remote-get').live('click', function(e)
  {
    $.getScript($(this).attr('href'));
    e.preventDefault();
  }).attr("rel", "nofollow");

  $.each(['remote-post', 'remote-put', 'remote-delete'], function(index, className) {
    var method = className.replace(/^remote\-(.+)$/,'$1');
    $('a.' + className).live('click', function(e) 
    {
      if ($(this).attr('data-confirm') && !confirm($(this).attr('data-confirm'))) 
        return false;

      if(method == 'delete')
      {
        $(this).attr('href', function ()
        {
          return this.href.replace('/delete', '');
        });
      }

      $.post($(this).attr('href'), "_method=" + method, null, "script");
      e.preventDefault();
    }).attr("rel", "nofollow");

    $('form.' + className).submitWithAjax();
  });

});
