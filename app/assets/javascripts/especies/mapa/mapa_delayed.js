
$(document).ready(function() {
    // Inicia el mapa
    cargaMapa('map');

    $('#map').css('height', $('#contenedor_mapa').height() - 30);

    $(window).resize(function () {
        $('#map').css('height', $('#contenedor_mapa').height() - 30);
        map.invalidateSize(true);
    });

    //TODO: Poner en el evento cuando se crea el mapa y acomodar este js
    $('#geodata_e_imagen_li > a, #map a.leaflet-control-fullscreen-button').click(function () {
        setTimeout(function(){
            $('#map').css('height', $('#contenedor_mapa').height() - 30);
            map.invalidateSize(true);
        },1000);
    });
});