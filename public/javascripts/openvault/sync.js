  
  function timestamp_to_s(timestamp) {
    var s = 0;
    if(typeof timestamp != 'string' || timestamp.indexOf(':') == -1) { return timestamp; }
    var t = timestamp.split(":");
  
    s = parseFloat(t[2]);
    s += trimParseInt(t[1]) * 60;
    s += trimParseInt(t[0]) * 60*60;
  
    return s;
  }

  function s_to_timestamp(time) {
	var t = new Array(0,0,0);

	t[2] = time;

	if(t[2] >= 60) {
		t[1] = parseInt(t[2]/60);
		t[2] -= t[1]*60;

		if(t[1] >=60) {
		t[0] = parseInt(t[1]/60);
		t[1] -= t[0]*60;
		}
	}

	if(t[0] < 10) { t[0] = "0" + t[0];}
	if(t[1] < 10) { t[1] = "0" + t[1];}
	if(t[2] < 10) { t[2] = "0" + t[2];}

	return t.join(':');
      

      
  }
  
  function trimParseInt(s) {
    if(s != undefined) {
      return s.replace(/^0+/,'');
    } else {
      return 0;
    }
  }

$(function() {

   if($('.datastream-video,.datastream-audio').length > 0 && $('.datastream-transcript').length > 0) {
     //select all timecode-enabled elements
     $('*[data-timecodebegin]').attr('data-timecode', true);
     $('*[data-timecodeend]').attr('data-timecode', true);
     smil_elements = $('*[data-timecode]');

     smil_elements.each(function(index) {
       //fill in missing timecode as best as possible
       if(($(this).data('timecodebegin')) == 'undefined') {
         var pred = smil_elements.slice(0, index).has('*[data-timecode]');
         $(this).data('timecodebegin', Math.max(timestamp_to_s(pred.grep(function(e) { return $(e).is('*[data-timecodeend]') }).first().data('timecodeend')), timestamp_to_s(pred.grep(function(e) { return $(e).is('*[data-timecodebegin]') }).first().data('timecodebegin'))));
       }

       if(($(this).data('timecodeend')) == 'undefined') {
         var pred = smil_elements.slice(0, index).has('*[data-timecode]');
         $(this).data('timecodeend', Math.min(timestamp_to_s(pred.grep(function(e) { return $(e).is('*[data-timecodebegin]') }).first().data('timecodebegin')), timestamp_to_s(pred.grep(function(e) { return $(e).is('*[data-timecodeend]') }).first().data('timecodeend'))));
       }
     });

     //convert hh:mm:ss.ff to seconds
     smil_elements.each(function() {
       var begin = timestamp_to_s($(this).data('timecodebegin'));
       var end = timestamp_to_s($(this).data('timecodeend'));
        $(this).data('begin_seconds', begin);
        $(this).data('end_seconds', end);
     });

     //sync the media with the transcript
     $(player).sync(smil_elements, { 'time': function() { return this.getPosition() }});
     smil_elements.bind('sync-on', function() { $(this).addClass('current'); });
     smil_elements.bind('sync-off', function() { 
       $('.last').removeClass('last');
       $(this).removeClass('current').addClass('last'); 
     });

     //sync the transcript with the media
     smil_elements.each(function() {
       $('<a class="sync">[sync]</a>').prependTo($(this)).bind('click', function() { player.seek($(this).parent().data('begin_seconds')); }) ;
     });
     if(smil_elements.length > 0) {
       $('<a class="sync">[sync]</a>').prependTo($('.datastream-actions')).bind('click', function() {
         if($('.current').length > 0) {
     $('.secondary-datastream').scrollTo($('.current'));
         } else {
     $('.secondary-datastream').scrollTo($('.last'));

         }
    return false;
  });
     }
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
      'pollingInterval' : 1000,
      'event': 'timeupdate'
    }

    $.extend( settings, options );

    if(settings['poll']) {
      setInterval(function() { $(media).trigger('timeupdate'); }, settings['pollInterval']);
    } 

    this.bind(settings['event'], function() {
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

