$(function() {
  var last_search = null;
  var i = 0;
  var max = 0;

  //$('.datastream-transcript').sausage({page: 'h3', content: function(i, $page) { return ''}, onClick: function(e, o) { $('.datastream-transcript').scrollTo($('h3', '.datastream-transcript').eq(o.i)); }});


   $('.datastream-action-search').bind('submit', function() {
     current_search = $('input:text', this).val();

     if(current_search != last_search) {
       $('.secondary-datastream').unhighlight().highlight(current_search);

       $('.tei-metadata .highlight').each(function() {
          $('.secondary-datastream .tei-name-' + $(this).parent().attr('id')).addClass('highlight');
          $(this).removeClass('highlight');
       });

       max = $('.secondary-datastream .highlight').length
     if(max == 0) {
       alert('No results found');
       return false;
     }

       last_search = current_search;
       i = 0;
     }

     next = $('.secondary-datastream .highlight').eq(i); 

     if(next.length == 0) {
       next = $('.secondary-datastream .highlight').first();
     }


     if(next.length == 0) {
       next = {top: 0}
     }

     $('.secondary-datastream').scrollTo(next);
     i++;
     if(i > max) {
       i = 0;
     }
     return false;
   });
});
