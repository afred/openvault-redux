var player = null;

$('#video-mp4,#audio-mp3,video,audio').each(function() {
  options =  {
    'flashplayer': '/swfs/player.swf',
    provider: 'http',
    'http.startparam':'start', 
     skin: '/swfs/glow.zip',
     events: {
       onTime: function() {
          $(this).trigger('timeupdate'); // HTML5 event
       }
     },
    'plugins': {
       'gapro-2': {}
     }

  }

  if($(this).is('audio')) {
   options['provider'] = 'sound';
    if($(this).prev('img').length > 0) {
      options['height'] = '28';
      options['controlbar'] = 'bottom';
    }
  }

  jw = jwplayer($(this).attr('id')).setup(options);

  if(player == null) {
    player = jw;
  }
});

var start = 0;
try {
  start = /t=(\d+)/.exec(location.hash).pop();
}
catch(err) {
}

if(start > 0) { 
  player.onPlay(function() { 
    if(start > 0) { 
      player.seek(start) 
      start = 0;
    }
  });
player.play();
}
