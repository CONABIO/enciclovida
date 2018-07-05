$(document).ready(function() {
    // Inicia el mapa
    cargaMapa('map');
    cargaRegistrosSnib(opciones.snib_url);
    //ponTamaño();

    $(window).resize(function () {
        ponTamaño();
    });

    //TODO: Poner en el evento cuando se crea el mapa y acomodar este js
    $('#geodata_e_imagen_li > a, #map a.leaflet-control-fullscreen-button').click(function () {
        setTimeout(function(){
            ponTamaño();
        },1000);
    });
});