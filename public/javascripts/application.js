// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults
//
    //add ajaxy dialogs to certain links, using the ajaxyDialog widget.
    Blacklight.do_more_facets_behavior = function () {
      $( Blacklight.do_more_facets_behavior.selector ).ajaxyDialog({
          width: $(window).width() / 2,  
          chainAjaxySelector: "a.next_page, a.prev_page, a.sort_change",        
          open: function() { $('#domsearch', this).domsearch($('ul.facet_extended_list', this)) }
      });
    };
    Blacklight.do_more_facets_behavior.selector = "a.more_facets_link";

    $(function() {
       $('.user_util_links a').ajaxyDialog({
        width: $(window).width() / 2,
        chainAjaxySelector: ".folderTools a, .search_history a"
         });
        });


$(function() {
    function timestamp_to_s(timestamp) {
      var s = 0;
              if(typeof timestamp != 'string' || timestamp.indexOf(':') == -1) { return timestamp; }
              var t = timestamp.split(":");

              s = parseFloat(t[2]);
              s += trimParseInt(t[1]) * 60;
              s += trimParseInt(t[0]) * 60*60;

              return s;
        }

   function trimParseInt(s) {
        if(s != undefined) {
            return s.replace(/^0+/,'');
        } else {
            return 0;
        }
  }

   media_selector = '.primary-datastream video, .primary-datastream audio';
   if($('.blacklight-catalog-show').length > 0 && $(media_selector).length > 0) {
     //select all timecode-enabled elements
     $('*[data-timecode_begin]').attr('data-timecode', true);
     $('*[data-timecode_end]').attr('data-timecode', true);
     smil_elements = $('*[data-timecode]');

     smil_elements.each(function(index) {
       //fill in missing timecode as best as possible
       if(($(this).data('timecode_begin')) == 'undefined') {
         var pred = smil_elements.slice(0, index).has('*[data-timecode]');
         $(this).data('timecode_begin', Math.max(timestamp_to_s(pred.grep(function(e) { return $(e).is('*[data-timecode_end]') }).first().data('timecode_end')), timestamp_to_s(pred.grep(function(e) { return $(e).is('*[data-timecode_begin]') }).first().data('timecode_begin'))));
       }

       if(($(this).data('timecode_end')) == 'undefined') {
         var pred = smil_elements.slice(0, index).has('*[data-timecode]');
         $(this).data('timecode_end', Math.min(timestamp_to_s(pred.grep(function(e) { return $(e).is('*[data-timecode_begin]') }).first().data('timecode_begin')), timestamp_to_s(pred.grep(function(e) { return $(e).is('*[data-timecode_end]') }).first().data('timecode_end'))));
       }
     });

     //convert hh:mm:ss.ff to seconds
     smil_elements.each(function() {
       var begin = timestamp_to_s($(this).data('timecode_begin'));
       var end = timestamp_to_s($(this).data('timecode_end'));
        $(this).data('begin_seconds', begin);
        $(this).data('end_seconds', end);
     });

     //sync the media with the transcript
     $(media_selector).sync(smil_elements);
     smil_elements.bind('sync-on', function() { $(this).addClass('current'); });
     smil_elements.bind('sync-off', function() { $(this).removeClass('current'); });

     //sync the transcript with the media
     smil_elements.each(function() {
       $('<a class="sync">[sync]</a>').prependTo($(this)).bind('click', function() { $(media_selector)[0].currentTime = $(this).parent().data('begin_seconds'); }) ;
     });
   }
    });

(function($) {
  $.fn.sync = function(target, options) {
    media = this;
    var settings = {
      'begin' : 'begin_seconds',
      'end' : 'end_seconds',
      'on' : function() { $(this).trigger('sync-on'); },
      'off' : function() { $(this).trigger('sync-off'); },
      'time' : function() { return this.currentTime },
      'poll' : false,
      'pollingInterval' : 1000
    }

    $.extend( settings, options );

    if(settings['poll']) {
      setInterval(function() { $(media).trigger('timeupdate'); }, settings['pollInterval']);
    } 

    this.bind('timeupdate', function() {
      t = jQuery.proxy(settings['time'], this)();
      target.each(function() {
       if($(this).data(settings['begin']) <= t && t <= $(this).data(settings['end'])) {
         if($(this).data('sync') != true) {
           $(this).data('sync', true);
           jQuery.proxy(settings['on'], this)();
         }
       } else {
         if($(this).data('sync') == true) {
           $(this).data('sync', false);
           jQuery.proxy(settings['off'], this)();
         }
       }
      });
    });

  }

}(jQuery));
