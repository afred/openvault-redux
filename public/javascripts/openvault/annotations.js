    $(function() {
       comments_dialog = $('#document .blacklight-comments a').ajaxyDialog({
         modal: false,
         dialogContainer: '#annotations_modal_dialog'
       });
       $('.tools .cite a').ajaxyDialog( {
         modal: false
       });
       $('.new_tag,.new_annotation').ajaxyDialog({
         modal: false,
         dialogContainer: '#annotations_modal_dialog',
         load: function(event, dialog) {
           md = $('.record_annotation_metadata', dialog).append($('.media_fragment_template .media_fragment').clone());
           if(typeof(player) != "undefined") {
             try {
             $('#comment_metadata_begin', md).val(s_to_timestamp(parseInt(player.getPosition())));
             $('#comment_metadata_end', md).val(s_to_timestamp(parseInt(player.getPosition())));
             } catch(error) {

             }
           }
         }
       });
      /* $('.user_util_links a').ajaxyDialog({
        width: $(window).width() / 2,
        chainAjaxySelector: ".folderTools a, .search_history a"
         });
        */
       $('a.comments').ajaxyDialog({
        width: $(window).width() / 2,
        modal: false,
         dialogContainer: '#annotations_modal_dialog'
         });

        try {
          start = /(comment-\d+)/.exec(location.hash).pop();
      

          scrollToComment = function(event, dialog) {
            comments_dialog.unbind('ajaxydialogafterdisplay');
            comment = $("." + start); 
             $('#annotations_modal_dialog').scrollTo(comment)
             comment.addClass('active');
          };
 comments_dialog.bind('ajaxydialogafterdisplay', scrollToComment)
          
          comments_dialog.first().ajaxyDialog("open");
        


         }
         catch(err) {
         }

        });

