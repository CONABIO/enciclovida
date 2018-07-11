$(document).ready(function() {
    // Inicia el mapa
    cargaMapa('map');

    // Para cargar los registros del SNIB
    if (opciones.snib_url != undefined)
        cargaEjemplaresSnib(opciones.snib_url);

    // Para cargar las observaciones de NaturaLista
    if (opciones.naturalista_url != undefined)
        cargaObservacionesNaturalista(opciones.naturalista_url);

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