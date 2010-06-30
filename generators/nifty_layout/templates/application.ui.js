jQuery.noConflict()(function($){
  $.refreshUI = function() {
    $("#content [data-ui=button], div[data-ui=dialog] [data-ui=button]").button();

    $("div[data-ui=dialog]:visible").dialog({
      modal: true,
      minHeight: 600,
      maxHeight: 800,
      width: 650,
      maxWith: 800,
      close: function(event, ui) {
        var openNewDialog = $("#content a[href][id^=get-new-" + this.id.split('-')[1] + "]:hidden");
        if(openNewDialog.length > 0)
        {
          var newDialog = $("div#new-" + openNewDialog.attr('id').split('-')[2] + "[data-ui=dialog]:hidden");
          if(newDialog.length > 0)
          {
            openNewDialog
              .removeAttr("data-remote")
              .removeAttr("data-method")
              .click(function(e){
                newDialog.show();
                $.refreshUI();
                newDialog.dialog("open");
                e.preventDefault();
              });
          }
          openNewDialog.show();
        }
      }
    })
    .submit(function(e) {
      $(this).ajaxSuccess(function(){$(this).dialog("close");});
      e.preventDefault();
    })
    .find("h2").remove();

  };

  $.refreshUI();
  $.ajaxSetup({   
    'success': function() {$.refreshUI();}
  });

  $.submitWithAjax = function(e) {
    var form = $(e.target).closest("form");
    $.post(form.attr("action"), form.serialize(), $.refreshUI() , "script");
    e.preventDefault();
  };

});
