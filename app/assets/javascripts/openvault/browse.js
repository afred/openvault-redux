$(function() {
  $('#browse input').hide();
   $('#browse select').bind('change', function() {
     $(this).closest('form').submit();
   });
});

