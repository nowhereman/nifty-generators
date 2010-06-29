jQuery.noConflict()(function($){
  $.refreshUI = function() {
    $("#content a[href], #content button, #content input:submit, .modal.dialog a[href], .modal.dialog button, .modal.dialog input:submit").button();

    $("div.modal.dialog:visible").dialog({
      modal: true,
      minHeight: 600,
      maxHeight: 800,
      width: 650,
      maxWith: 800,
      closeText: 'fermer',
      close: function(event, ui) {
        var openNewDialog = $("#content a[href][id^=get-new-" + this.id.split('-')[1] + "]:hidden");
        if(openNewDialog.length > 0)
        {
          var newDialog = $("div#new-" + openNewDialog.attr('id').split('-')[2] + ".modal.dialog:hidden");
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
    'error': function() {
      $("div.flash").remove();
      var flash_message = $("<div id='flash-alert' class='flash'>Une erreur Ajax est survenue.</div>");
      $("div#container div#content").prepend(flash_message);
      window.location.hash = "#";
    },
    'success': function() {$.refreshUI();}
  });

  $.submitWithAjax = function(e) {
    var form = $(e.target).closest("form");
    $.post(form.attr("action"), form.serialize(), $.refreshUI() , "script");
    e.preventDefault();
  };

});
