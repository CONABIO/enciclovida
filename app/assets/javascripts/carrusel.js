//=require sly

$(document).on('ready', function(){
    /* Este contenido se mandará a llamar una vez cargue el DOM, así la petición se realizará con el cliente y
     y la respuesta no dependerá del API (tiempo de respuesta) */

    $.ajax(
        {
            url: NATURALISTA_URL,
            type: 'GET',
            dataType: 'json'
        }).done(function(json){
            if (jQuery.isEmptyObject(json))
            {
                console.log('esta vacia la respuesta de naturalista');
            } else {

                if (jQuery.isEmptyObject(json.default_photo) && json.taxon_photos.length == 0)
                    $('#contenedor_fotos').remove();
                else {
                    $.ajax(
                        {
                            url: '/especies/' + TAXON.id + '/fotos_carrusel',
                            type: 'POST',
                            data: {
                                foto_default: JSON.stringify(json.default_photo),
                                fotos: JSON.stringify(json.taxon_photos)
                            }
                        }).done(function(fotos){
                            $('#contenedor_mapa').removeClass().addClass('col-xs-12 col-sm-10 col-md-7 col-lg-7 col-xs-offset-0 col-sm-offset-1 col-md-offset-0');
                            $('#contenedor_fotos').html(fotos);
                            inicia_carrusel();
                        }).error(function(error){
                            console.log('error');
                        });
                }
            }
        });
});


function inicia_carrusel() {
//Para que la imagen inicial no se desborde antes de que inicie el carrusel:
    $('#foto-carrusel-interna').css('max-height', $('#contenedor_fotos').height() - 100 - $('#foto-carrusel > p').height());

    var sly = new Sly('#carrusel', {
        horizontal: 1,
        // Item based navigation //
        itemNav: 'centered',
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
        scrollBar: '.scrollbar',
        dragHandle: 1,
        dynamicHandle: 1,
        clickBar: 1,
        syncSpeed: 1,
        // Pagesbar //
        // Navigation buttons //
        // Automated cycling //
        cycleBy: 'items',
        cycleInterval: 3500,
        pauseOnHover: 1,
        // Mixed options //
        // Classes //
        activeClass: 'seleccionada'
    }).init();
//En el evento de que una foto se convierte en activa, se modifica la foto central
    sly.on('active', function (eventName) {
        // Para cambiar la atribucion de la foto (cŕeditos) tanto en texto, como en ligas
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