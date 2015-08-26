/**
 * Created with JetBrains RubyMine.
 * User: calonso
 * Date: 1/27/14
 * Time: 4:11 PM
 * To change this template use File | Settings | File Templates.
 */

$(document).ready(function()
{
    open = function(event, ui)
    {
        var $input = $(event.target),
            $results = $input.autocomplete("widget"),
            top = $results.position().top,
            height = $results.height(),
            inputHeight = $input.height(),
            newTop = top - height - inputHeight;

        $results.css("top", newTop + "px");
    }

    despliegaOcontrae = function(id)
    {
        var sufijo = id.substring(5);
        //Verifica que el nodo que se le dio clic este vacio
        if ($("#nodo_" + sufijo + " li").length > 0)
        {
            $("#nodo_" + sufijo + " li").remove();
        } else {
            $.ajax(
                {
                    url: "/especies/arbol",
                    data: {
                        id: sufijo,
                        accion: true
                    }
                }).done(function(nodo)
                {
                    return $("#nodo_" + sufijo).append(nodo);
                });
        }
        return false;
    }

    $.fn.loadingShades = function(e, options)
    {
        options = options || {}
        if (e && e == 'close') {
            $(this).shades(e, options)
        } else {
            var txt = e || 'Loading...',
                cssClass = options.cssClass || 'bigloading',
                msg = '<div class="loadingShadesMsg"><span class="loading '+cssClass+' status inlineblock">'+txt+'</span></div>'
            options = $.extend(true, options, {
                css: {'background-color': 'white'},
                content: msg
            })
            $(this).shades('open', options)
            var status = $('.shades .loading.status', this)
            status.css({
                position: 'absolute',
                top: options.top || '50%',
                left: options.left || '50%',
                marginTop: (-1 * status.outerHeight() / 2) + 'px',
                marginLeft: (-1 * status.outerWidth() / 2) + 'px'
            })
        }
    }

    $.fn.shades = function(e, options)
    {
        options = options || {}
        elt = this[0]
        switch (e) {
            case 'close':
                $(elt).find('.shades:last').hide()
                break;
            case 'remove':
                $(elt).find('.shades:last').remove()
                break;
            default:
                var shades = $(elt).find('.shades:last')[0] || $('<div class="shades"></div>'),
                    underlay = $('<div class="underlay"></div>'),
                    overlay = $('<div class="overlay"></div>').html(options.content)
                $(shades).html('').append(underlay, overlay)
                if (options.css) { $(underlay).css(options.css) }
                if (elt != document.body) {
                    $(elt).css('position', 'relative')
                    $(shades).css('position', 'absolute')
                    $(underlay).css('position', 'absolute')
                }
                $(elt).append(shades)
                $(shades).show()
                break;
        }
    }

    $.fn.centerDialog = function()
    {
        if ($(this).children().length == 1) {
            var newHeight = $(':first', this).height() + 100
        } else {
            var newHeight = $(this).height() + 100
        }
        var maxHeight = $(window).height() * 0.8
        if (newHeight > maxHeight) { newHeight = maxHeight };
        $(this).dialog('option', 'height', newHeight)
        $(this).dialog('option', 'position', {my: 'center', at: 'center', of: $(window)})
    }

    cambia_locale = function(locale)
    {
        $.ajax(
            {
                url: "/usuarios/cambia_locale",
                type: 'POST',
                data: {
                    locale: locale
                }
            }).done(function()
            {
                location.reload(true);
                return false;
            });
        return false;
    }

    /*
     Cuando el usuario elige un taxon en la vists avanzada, las categorias
     taxonimicas se despliegan segun las asociadas
    */
    cat_tax_asociadas = function(id)
    {
        $.ajax(
            {
                url: "/especies/cat_tax_asociadas",
                type: 'GET',
                data: {
                    id: id
                }
            }).done(function(html)
            {
                $('#datos_cat').html('').html(html);
                $('#panelCategoriaTaxonomicaPt').show();
            });
    }

    scrolling_page = function(objeto, por_pagina, url)
    {
        $(objeto).scrollPagination({
            nop     : por_pagina, // The number of posts per scroll to be loaded
            offset  : 2, // Initial offset, begins at 0 in this case
            error   : '', // When the user reaches the end this is the message that is
            // displayed. You can change this if you want.
            delay   : 500, // When you scroll down the posts will load after a delayed amount of time.
                           // This is mainly for usability concerns. You can alter this as you see fit
            scroll  : true, // The main bit, if set to false posts will not load as the user scrolls.
            // but will still load if the user clicks.
            url     : url
        });
    }
});

cambiaSidebar = function(){
    $('#filtros').toggleClass('sidebar_lupa col-xs-1 col-sm-1 col-md-1 col-lg-1 col-xs-5 col-sm-4 col-md-4 col-lg-3');
    $('#filtros > span').toggleClass('glyphicon-search glyphicon-remove ');
    $('#filtros > div').toggleClass('hidden');
};

var fondo = 0;
cambiafondo = function(){
    fondo = fondo + 1;
    url = "url(\"/assets/app/fondo_"+fondo+".jpg\")";
    //console.log(url);
    $('body').css('background-image',url);
    if (fondo == 8){
        fondo = -1;
    }
};
$(document).ready(function () {
    (function cambiaFondoAuto(){
        url = "url(\"/assets/app/fondo_"+fondo+".jpg\")";
        //console.log(url);
        $('body').css('backgroundImage', function () {
            $('#img-fondo').animate({backgroundColor: 'rgba(40,40,40, 0)'}, 2500, function () {
                setTimeout(function () {
                    $('#img-fondo').animate({backgroundColor: 'rgba(40,40,40, 1)'}, 2500);}, 10000);
            });
            return url;
        });
        if (fondo == 8){
            fondo = -1;
        }
        fondo = fondo + 1;
        setTimeout(cambiaFondoAuto, 15000);
    })();
});
