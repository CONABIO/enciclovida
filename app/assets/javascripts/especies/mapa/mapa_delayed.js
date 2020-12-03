$(document).ready(function() {
    // Inicia el mapa
    cargaMapa('map', { pantalla_comp: true });

    // Para cargar las observaciones de NaturaLista
    if (opciones.naturalista_url !== undefined)
        cargaObservacionesNaturalista(opciones.naturalista_url);

    // Para cargar los registros del SNIB
    if (opciones.snib_url != undefined)
        cargaEjemplaresSnib(opciones.snib_url);

    // Para cargar las capas del geoserver
    if (opciones.geoserver_url !== undefined)
        cargaCapasGeoserver(opciones.geoserver_url);

    $(window).resize(function () {
        ponTamaño();
    });
    
});