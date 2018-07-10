$(document).ready(function() {
    // Inicia el mapa
    cargaMapa('map');

    // Para cargar los datos del SNIB
    if (opciones.geodatos.snib_mapa_json == undefined)
    {
        if (opciones.snib_url != undefined)
            cargaRegistrosSnib(opciones.snib_url);
    } else {
        opciones.solo_coordenadas = true;
        cargaRegistrosSnib(opciones.geodatos.snib_mapa_json);
    }

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