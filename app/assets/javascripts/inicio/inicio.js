var onYouTubePlayerAPIReady = function()
{
    tv = new YT.Player('tv', {events: {'onReady': onPlayerReady, 'onStateChange': onPlayerStateChange}, playerVars: playerDefaults});
};

var onPlayerReady = function()
{
    tv.loadVideoById(vid[0]);
    tv.mute();
};

var onPlayerStateChange = function(e) {
    if (e.data === 1){
        $('#tv').addClass('active');
        $('header').css('background-image', 'none');
    } else if (e.data === 0){
        tv.seekTo(vid[0].startSeconds);
    }
};

var vidRescale = function()
{
    var w = $(window).width(),
        h = $(window).height();
    if (w/h > 16/9){
        tv.setSize(w, w/16*9);
        $('.tv .screen').css({'left': '0px'});
    } else {
        tv.setSize(h/9*16, h);
        $('.tv .screen').css({'left': -($('.tv .screen').outerWidth()-w)/2});
    }
    setPaddingHeader();
};

var setPaddingHeader = function()
{
    var vacio = $(window).height()-$('#brandBar').height();
    $('header').css('padding-bottom', (vacio));
    $('#news').css('margin-top', (30-vacio));
    $('#issues').css('height', (vacio-150));
    $('#buscadores').css('margin-top', (1-vacio));
};

$(document).ready(function(){
    tv, playerDefaults = {autoplay: 0, autohide: 1, modestbranding: 0, rel: 0, showinfo: 0, controls: 0, disablekb: 1, enablejsapi: 0, iv_load_policy: 3};
    vid = [{'videoId': '8NanLwCSneM', 'startSeconds': 0, 'suggestedQuality': 'hd480'}];

    setPaddingHeader();
    var tag = document.createElement('script');
    tag.src = 'https://www.youtube.com/player_api';
    var firstScriptTag = document.getElementsByTagName('script')[0];
    firstScriptTag.parentNode.insertBefore(tag, firstScriptTag);

    $(window).on('load', function(){
        vidRescale();
    });

    $(window).on('resize', function(){
        vidRescale();
    });
});

