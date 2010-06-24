// Based on :
// http://blog.lawrencepit.com/2008/09/04/unobtrusive-jquery-rails
// http://railscasts.com/episodes/136-jquery
// http://brandonaaron.net/blog/2009/02/25/unobtrusive-destroy-links-in-rails-using-jquery

jQuery.noConflict()(function($){
  // code using jQuery
  // All ajax requests will trigger the wants.js block
  // of +respond_to do |wants|+ declarations
  $.ajaxSetup({
    'beforeSend': function(xhr) {xhr.setRequestHeader("Accept", "text/javascript")}
  });
  
  function submitWithAjax(e) {
    var form = $(e.target).closest("form");
    $.post(form.attr("action"), form.serialize(), null, "script");
    e.preventDefault();
  }

  // Buggy with jQuery 1.4.2 and IEs
  /*jQuery.fn.submitWithAjax = function() {
    this.live('submit',function(e)
    {
      $.post(this.action, $(this).serialize(), null, "script");
      e.preventDefault();
    });
    return this;
  };*/

  $(document).ready(function($)
  {
  // Behaviours
    // All non-GET requests will add the authenticity token
    // if not already present in the data packet
    $("body").bind("ajaxSend", function(elm, xhr, s)
    {
      if (s.type == "GET")
        return;

      if (s.data && s.data.match(new RegExp("\\b" + window._auth_token_name + "=")))
        return;

      if (s.data)
      {
        s.data = s.data + "&";
      }
      else
      {
        s.data = "";
        // if there was no data, jQuery didn't set the content-type
        xhr.setRequestHeader("Content-Type", s.contentType);
      }
      s.data = s.data + encodeURIComponent(window._auth_token_name) + "=" + encodeURIComponent(window._auth_token);
    });

  // More behaviours
    // All A and FORM tags with attribute 'data-remote' and values 'get', 'post', 'put' or 'delete' will perform an ajax call
    $('a[data-remote=true][data-method=get]').live('click', function(e)
    {
      $.getScript($(this).attr('href'));
      e.preventDefault();
    }).attr("rel", "nofollow");

    $.each(['post', 'put', 'delete'], function(index, method) {
      $('a[data-remote=true][data-method=' + method + ']').live('click', function(e)
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

      $('form[data-remote=true][data-method=' + method + ']').live('submit', submitWithAjax);
      
      // Fix jQuery 1.4.2 live submit bug with IEs
      if($.browser.msie)
        $('form[data-remote=true][data-method=' + method + '] input[type=submit]').live('click', submitWithAjax);
    });
  });
});
