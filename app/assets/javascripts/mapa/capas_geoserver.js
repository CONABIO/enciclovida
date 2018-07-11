/**
 * Borra capas anteriores y carga las nuevas
 * @param url
 */
var cargaCapasGeoserver = function(url)
{
    borraCapasAnterioresGeoserver();
    capaDistribucionGeoserver(url);
};

/**
 * Borra capas anteriores
 */
var borraCapasAnterioresGeoserver = function()
{
    if (distribucionLayer == undefined) return;
    if (map.hasLayer(distribucionLayer))
    {
        map.removeControl(geoserver_control);
        map.removeLayer(distribucionLayer);
    }
};

/**
 * La simbologia dentro del mapa
 */
var leyendaGeoserver = function()
{
    geoserver_control = L.control.layers({}, {}, {collapsed: false, position: 'bottomleft'}).addTo(map);

    distribucionLayer.addTo(map);
    legend_control.addOverlay(distribucionLayer,
        "<b>Distribución potencial (CONABIO)</b>"
    );
};

/**
 * Crear y carga la capa de distribucion
 * @param url
 */
var capaDistribucionGeoserver = function (url) {
    distribucionLayer = L.tileLayer.wms(url, {
        layers: opciones.geodatos.geoserver_layer,
        format: 'image/png',
        transparent: true,
        opacity:.5,
        zIndex: 4
    });

    map.addLayer(distribucionLayer);
    leyendaGeoserver();

    // Para cuando se cambie de layer ponga enfrente el mapa de distribucion
    map.addEventListener('baselayerchange', function(){
        distribucionLayer.bringToFront();
    });

    distribucionLayer.bringToFront();  // Para desde un inicio que se muestre el mapa de distribucion
};