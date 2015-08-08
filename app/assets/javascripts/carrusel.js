//= require sly

//Para que la imagen inicial no se desborde antes de que inicie el carrusel:
$('#foto-carrusel-interna').css('max-height',$('#contenedor_fotos').height()-100-$('#foto-carrusel > p').height());

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
    activeClass:   'seleccionada'
}).init();
//En el evento de que una foto se convierte en activa, se modifica la foto central
sly.on('active', function (eventName) {
    // Para cambiar la atribucion de la foto (cŕeditos) tanto en texto, como en ligas
    $('#foto-atribucion').html($('img.seleccionada').attr('data-attribution'));
    $('.enlace-atribucion').attr('href',$('img.seleccionada').attr('data-large'));
    //Para cambiar la foto interna y establecer el tamaño máximo
    $('#foto-carrusel-interna').attr('src',$('img.seleccionada').attr('data-large'));
    $('#foto-carrusel-interna').css('max-height',$('#contenedor_fotos').height()-100-$('#foto-carrusel > p').height());
});
$(window).resize(function(e) {
    $('#carrusel').sly('reload');

});
