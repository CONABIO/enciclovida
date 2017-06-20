//=require sly

$(document).on('ready', function(){
    /* Este contenido se mandará a llamar una vez cargue el DOM, así la petición se realizará con el cliente y
     y la respuesta no dependerá del API (tiempo de respuesta) */

    if (typeof INATURALIST_API == null)
    {
        $.ajax(
            {
                url: INATURALIST_API,
                type: 'GET',
                dataType: 'json'
            }).done(function (json) {
                if (jQuery.isEmptyObject(json)) {
                    $('#contenedor_fotos').remove();
                    if (jQuery.isEmptyObject(GEO)) $('#sin_datos').html('Lo sentimos, pero no contamos con una imagen o geodato');
                } else {

                    if (json.total_results == 0) {
                        $('#contenedor_fotos').remove();
                        if (jQuery.isEmptyObject(GEO)) $('#sin_datos').html('Lo sentimos, pero no contamos con una imagen o geodato');
                    } else if (json.results[0].taxon_photos.length == 0) {
                        $('#contenedor_fotos').remove();
                        if (jQuery.isEmptyObject(GEO)) $('#sin_datos').html('Lo sentimos, pero no contamos con una imagen o geodato');
                    } else {
                        $.ajax(
                            {
                                url: '/especies/' + TAXON.id + '/fotos-referencia',
                                type: 'POST',
                                data: {
                                    fotos: JSON.stringify(json.results[0].taxon_photos.slice(0, 5))
                                }
                            }).done(function (fotos) {
                                if (jQuery.isEmptyObject(GEO))
                                    $('#contenedor_fotos').removeClass().addClass('col-xs-8 col-sm-8 col-md-8 col-lg-8 col-xs-offset-2 col-sm-offset-2 col-md-offset-2 col-lg-offset-2');
                                else {
                                    $('#contenedor_fotos').removeClass().addClass('col-xs-12 col-sm-10 col-md-5 col-lg-5 col-xs-offset-0 col-sm-offset-1 col-md-offset-0');
                                    $('#contenedor_mapa').removeClass().addClass('col-xs-12 col-sm-10 col-md-7 col-lg-7 col-xs-offset-0 col-sm-offset-1 col-md-offset-0');
                                }

                                $('#contenedor_fotos').html(fotos);
                                inicia_carrusel();

                            }).error(function (error) {
                                $('#contenedor_fotos').remove();
                                if (jQuery.isEmptyObject(GEO)) $('#sin_datos').html('Lo sentimos, pero no contamos con una imagen o geodato');
                            });
                    }
                }
            }).error(function (error) {
                $('#contenedor_fotos').remove();
            });

    } else {
        $('#contenedor_fotos').remove();
        if (jQuery.isEmptyObject(GEO)) $('#sin_datos').html('Lo sentimos, pero no contamos con una imagen o geodato');
    }

});


function inicia_carrusel() {
//Para que la imagen inicial no se desborde antes de que inicie el carrusel:
    $('#foto-carrusel-interna').css('max-height', $('#contenedor_fotos').height() - 100 - $('#foto-carrusel > p').height());

    var sly = new Sly('#carrusel', {
        horizontal: 1,
        // Item based navigation //
        itemNav: 'basic',
        smart: 1,
        activateOn: 'click',
        // Scrolling //
        scrollSource: '#carrusel',
        scrollBy: 1,
        // Dragging //
        mouseDragging: 1,
        touchDragging: 1,
        elasticBounds: 1,
        startAt: 0,
        // Scrollbar //
        // Pagesbar //
        // Navigation buttons //
        // Automated cycling //
        cycleBy: 'items',
        cycleInterval: 5000,
        pauseOnHover: 1,
        // Mixed options //
        // Classes //
        activeClass: 'seleccionada'
    }).init();
//En el evento de que una foto se convierte en activa, se modifica la foto central
    sly.on('active', function (eventName) {
        // Para cambiar la atribucion de la foto (créditos) tanto en texto, como en ligas
        $('#foto-atribucion').html($('img.seleccionada').attr('data-attribution'));
        $('.enlace-atribucion').attr('href', $('img.seleccionada').attr('data-native-page-url'));
        //Para cambiar la foto interna y establecer el tamaño máximo
        $('#foto-carrusel-interna').attr('src', $('img.seleccionada').attr('data-large'));
        $('#foto-carrusel-interna').css('max-height', $('#contenedor_fotos').height() - 100 - $('#foto-carrusel > p').height());
    });

    $(window).resize(function (e) {
        $('#carrusel').sly('reload');

    });
}