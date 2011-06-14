   $(function() {
     var ias;
     if($('.datastream-image img').length > 0) {
      ias = $('.datastream-image img').imgAreaSelect({
        handles: true,
          instance: true,
        onSelectEnd: function(img, selection) { $('#comment_metadata_crop, input[name="comment[metadata][crop]"]').val(JSON.stringify(selection)); }
      });
     }

       comments_dialog = $('#document .blacklight-comments a').ajaxyDialog({
         modal: false,
         dialogContainer: '#annotations_modal_dialog'
       });
       $('.tools .cite a').ajaxyDialog( {
         modal: false
       });
       $('.new_tag,.new_annotation,a.comments').ajaxyDialog({
         modal: false,
        width: $(window).width() / 3,
         dialogContainer: '#annotations_modal_dialog',
         chainAjaxySelector: "a:not([target]),form:not([target])",
         load: function(event, dialog) {
           md = $('.record_annotation_metadata', dialog).append($('.media_fragment_template .media_fragment').clone());
           try {
             if(typeof(player) != "undefined") {
               $('#comment_metadata_begin', md).val(s_to_timestamp(parseInt(player.getPosition())));
               $('#comment_metadata_end', md).val(s_to_timestamp(parseInt(player.getPosition())));
             }

             if(typeof(ias) != "undefined") {
               if(ias.getSelection().width == 0) {
                 img = $('.datastream-image img');
                  ias.setSelection(0, 0, img.width(), img.height());
                  ias.setOptions({show: true});
                  ias.update();
               }
             }
           } catch(error) {

           }
         }
       });
      /* $('.user_util_links a').ajaxyDialog({
        width: $(window).width() / 2,
        chainAjaxySelector: ".folderTools a, .search_history a"
         });
        */

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

          $('.comment_view').live('click', function() { 
              var metadata = JSON.parse($('.comment_metadata', $(this).parent()).html());
              if(typeof(player) != "undefined") {
                player.play();
                player.seek(timestamp_to_s(metadata.begin));
              }

              if(typeof(ias) != "undefined") {
                var crop = JSON.parse(metadata.crop);

                ias.setSelection(crop.x1, crop.y1, crop.x2, crop.y2);
                ias.setOptions({show: true});
                ias.update();
              }
            return false;

          });


        });

