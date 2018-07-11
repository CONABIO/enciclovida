/**
 * Borra ejemplares anteriores y carga los nuevos
 * @param url
 */
var cargaCapasGeoportal = function(url)
{
    borraCapasAnterioresGeoportal();
    capaDistribucionGeoportal(url);
};

/**
 * Borra capas anteriores
 */
var borraCapasAnterioresGeoportal = function()
{
    if (distribucionLayer == undefined) return;
    if (map.hasLayer(distribucionLayer))
    {
        map.removeControl(geoportal_control);
        map.removeLayer(distribucionLayer);
    }
};

/**
 * La simbologia dentro del mapa
 */
var leyendaGeoportal = function()
{
    geoportal_control = L.control.layers({}, {}, {collapsed: false, position: 'bottomleft'}).addTo(map);

    distribucionLayer.addTo(map);
    legend_control.addOverlay(distribucionLayer,
        "<b>Distribución potencial (CONABIO)</b>"
    );
};

/**
 * Crear y carga la capa de distribucion
 * @param url
 */
var capaDistribucionGeoportal = function (url) {
    distribucionLayer = L.tileLayer.wms(url, {
        layers: GEO.geoserver_layer,
        format: 'image/png',
        transparent: true,
        opacity:.5,
        zIndex: 4
    });

    map.addLayer(distribucionLayer);
    leyendaGeoportal();

    // Para cuando se cambie de layer ponga enfrente el mapa de distribucion
    map.addEventListener('baselayerchange', function(){
        distribucionLayer.bringToFront();
    });

    distribucionLayer.bringToFront();  // Para desde un inicio que se muestre el mapa de distribucion
};