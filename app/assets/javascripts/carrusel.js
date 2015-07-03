//= require sly

$(document).ready(function() {
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
//                releaseSwing: 1,
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
        cycleInterval: 3000,
        pauseOnHover: 1,
        // Mixed options //
        // Classes //
        activeClass:   'seleccionada'
    }).init();
    sly.on('active', function (eventName) {
        x=$('img.seleccionada').attr('data-large');
        console.log(x);
        $('#foto-carrusel > img').attr('src',x);
    });
});
$(window).resize(function(e) {
    $frame.sly('reload');
});