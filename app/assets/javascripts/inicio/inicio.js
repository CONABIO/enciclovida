var onYouTubePlayerAPIReady = function(){
    tv = new YT.Player('tv', {events: {'onReady': onPlayerReady, 'onStateChange': onPlayerStateChange}, playerVars: playerDefaults});
};

var onPlayerReady = function(){
    tv.loadVideoById(vid[0]);
    tv.mute();
};

var onPlayerStateChange = function(e){
    if (e.data === 1){
        $('#tv').addClass('active');
        $('header').css('background-image', 'none');
    } else if (e.data === 0){
        tv.seekTo(vid[0].startSeconds);
    }
};

var vidRescale = function(){
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

var setPaddingHeader = function(){
    $('header').css('padding-bottom', ($(window).height() - $('#brandBar').height() - 472));
};

$(document).ready(function(){
    tv, playerDefaults = {autoplay: 0, autohide: 1, modestbranding: 0, rel: 0, showinfo: 0, controls: 0, disablekb: 1, enablejsapi: 0, iv_load_policy: 3};
    vid = [{'videoId': 'RBVRckQ8omU', 'startSeconds': 0, 'suggestedQuality': 'hd720'}];

    setPaddingHeader();
    if( !(/Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(navigator.userAgent)) ) {
        var tag = document.createElement('script');
        tag.src = 'https://www.youtube.com/player_api';
        var firstScriptTag = document.getElementsByTagName('script')[0];
        firstScriptTag.parentNode.insertBefore(tag, firstScriptTag);

        //evento q hace q las especies destacadas se contraigan de manera "suave" (solo activarlo en desktop en movil no tiene caso)
        /*$('#especies-destacadas .col').mouseenter(function(){
            $( this ).addClass('col-5');
        }).mouseleave(function(){
            $( this ).removeClass('col-5');
        });*/
        $('#especies-destacadas .col').hover(function(){$(this).toggleClass('col-5')});
        $('#especies-destacadas').hover(function(){$('#especies-destacadas div.col:first-of-type').toggleClass('col-4')});
    }

    $(window).on('load', function(){
        vidRescale();
    });

    $(window).on('resize', function(){
        vidRescale();
    });
});

