/**
 * Created with JetBrains RubyMine.
 * User: calonso
 * Date: 1/27/14
 * Time: 4:11 PM
 * To change this template use File | Settings | File Templates.
 */

// Para validar el correo
var correoValido = function (correo)
{
    var pattern = /^([a-z\d!#$%&'*+\-\/=?^_`{|}~\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF]+(\.[a-z\d!#$%&'*+\-\/=?^_`{|}~\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF]+)*|"((([ \t]*\r\n)?[ \t]+)?([\x01-\x08\x0b\x0c\x0e-\x1f\x7f\x21\x23-\x5b\x5d-\x7e\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF]|\\[\x01-\x09\x0b\x0c\x0d-\x7f\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF]))*(([ \t]*\r\n)?[ \t]+)?")@(([a-z\d\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF]|[a-z\d\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF][a-z\d\-._~\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF]*[a-z\d\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])\.)+([a-z\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF]|[a-z\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF][a-z\d\-._~\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF]*[a-z\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])\.?$/i;
    return pattern.test(correo);
};

$(document).ready(function(){

    $.fn.loadingShades = function(e, options){
        options = options || {};
        if (e && e == 'close') {
            $(this).shades(e, options)
        } else {
            var txt = e || 'Loading...',
                cssClass = options.cssClass || 'bigloading',
                msg = '<div class="loadingShadesMsg"><span class="loading '+cssClass+' status inlineblock">'+txt+'</span></div>';
            options = $.extend(true, options, {
                css: {'background-color': 'white'},
                content: msg
            });
            $(this).shades('open', options);
            var status = $('.shades .loading.status', this);
            status.css({
                position: 'absolute',
                top: options.top || '50%',
                left: options.left || '50%',
                marginTop: (-1 * status.outerHeight() / 2) + 'px',
                marginLeft: (-1 * status.outerWidth() / 2) + 'px'
            });
        }
    };

    $.fn.shades = function(e, options){
        options = options || {};
        elt = this[0];
        switch (e) {
            case 'close':
                $(elt).find('.shades:last').hide();
                break;
            case 'remove':
                $(elt).find('.shades:last').remove();
                break;
            default:
                var shades = $(elt).find('.shades:last')[0] || $('<div class="shades"></div>'),
                    underlay = $('<div class="underlay"></div>'),
                    overlay = $('<div class="overlay"></div>').html(options.content);
                $(shades).html('').append(underlay, overlay);
                if (options.css) { $(underlay).css(options.css) }
                if (elt != document.body) {
                    $(elt).css('position', 'relative');
                    $(shades).css('position', 'absolute');
                    $(underlay).css('position', 'absolute')
                }
                $(elt).append(shades);
                $(shades).show();
                break;
        }
    };

    $.fn.centerDialog = function()
    {
        if ($(this).children().length == 1) {
            var newHeight = $(':first', this).height() + 100
        } else {
            var newHeight = $(this).height() + 100
        }
        var maxHeight = $(window).height() * 0.8;
        if (newHeight > maxHeight){
            newHeight = maxHeight
        }
        $(this).dialog('option', 'height', newHeight);
        $(this).dialog('option', 'position', {my: 'center', at: 'center', of: $(window)});
    };

    cambia_locale = function(locale){
        $.ajax(
            {
                url: "/usuarios/cambia_locale",
                type: 'POST',
                data: {
                    locale: locale
                }
            }).done(function(){
                location.reload(true);
                return false;
            });
        return false;
    };
});

var fondo = 1;
cambiaFondo = function(){
    fondo = ((fondo < 16) ? fondo+1 : 1);//ya q puede darse el caso de q aumente mientras esta la transición
    url = "url(\"/fondos/"+((fondo < 10) ? "0"+fondo : fondo)+".jpg\")";
    $('#img-fondo').css('background-image',url);
};


/*$(document).ready(function (){
    var bgrotater = setInterval(function() {
        if (fondo==16) fondo=0;
        $('#img-fondo').animate({opacity: 0}, 1500, function(){
            $("#img-fondo").css("background-image", "url(\"/fondos/"+((fondo < 10) ? "0"+fondo : fondo)+".jpg\")");
        }).animate({opacity: 1}, 1500);
        fondo++;
    }, 60000);
});*/

$(document).ready(function(){
    $('.btn-title').each(function(){
        $(this).attr('tooltip-title', $(this).attr('title'));
        $(this).removeAttr('title');
    });
});
//Variable para ofuscar correo
var co = ["xm.bo","g.oiba","noc","@adivol","cicne:o","tliam"];

//Para automáticamente hacer un resize a la cajita de la busqueda básica se puede (y debe) MEJORAR
//Tambien para deshacer lo pestañoso de as pestañas, IDEM 210416
$(document).ready(function(){
    if (window.innerWidth < 992){
        $('#b_cientifico .input-group, #b_comun .input-group').addClass('input-group-lg');
        $('#pestañas > ul.nav').addClass('nav-stacked').removeClass('nav-tabs');
    }else{
        $('#b_cientifico .input-group, #b_comun .input-group').removeClass('input-group-lg');
        $('#pestañas > ul.nav').addClass('nav-tabs').removeClass('nav-stacked');
    }
    $(window).resize(function(){
        if (window.innerWidth < 992){
            $('#b_cientifico .input-group, #b_comun .input-group').addClass('input-group-lg');
            $('#pestañas > ul.nav').addClass('nav-stacked').removeClass('nav-tabs');
        }else{
            $('#b_cientifico .input-group, #b_comun .input-group').removeClass('input-group-lg');
            $('#pestañas > ul.nav').addClass('nav-tabs').removeClass('nav-stacked');
        }
    });
});