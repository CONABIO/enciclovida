/**
 * Inicializa el mapa
 * @param id
 * @param overlay
 */
var cargaMapa = function (id, overlay, opc)
{
    // Por si viene vacia la variable opc
    if (opc === undefined) opc = {};

    // El default de leaflet
    var OSM_layer = L.tileLayer('http://{s}.tile.osm.org/{z}/{x}/{y}.png',{
        zIndex: 1,
        noWrap: true
    });

    // Google terrain map layer
    var GTM_layer = L.tileLayer('http://{s}.google.com/vt/lyrs=p&x={x}&y={y}&z={z}',{
        subdomains:['mt0','mt1','mt2','mt3'],
        zIndex: 2,
        noWrap: true
    });
    // Google Hybrid
    var GHM_layer = L.tileLayer('http://{s}.google.com/vt/lyrs=y&x={x}&y={y}&z={z}',{
        subdomains:['mt0','mt1','mt2','mt3'],
        zIndex: 3,
        noWrap: true
    });

    var place = [23.79162789, -102.04376221];

    map = L.map(id, {
        zoomControl: false,
        doubleClickZoom: false,
        minZoom: 4,
        layers: [     // Existe un bug poniendo primero los layes de google
            OSM_layer,
            GTM_layer,
            GHM_layer
        ]
    });

    var zoom = L.control.zoom({
        zoomInTitle: 'Acercarse',
        zoomOutTitle: 'Alejarse',
        position: 'topright'
    });

    // https://github.com/brunob/leaflet.fullscreen
    var fullscreen = L.control.fullscreen({
        position: 'topright',
        title: 'Pantalla completa',
        titleCancel: 'Salir de pantalla completa'
    });

    map.setView(place, 5);  // Default place and zoom

    // Para poner las capas iniciales de los mapas
    var baseMaps = {
        "Open Street Maps": OSM_layer,
        "Vista de terreno": GTM_layer,
        "Vista Híbrida": GHM_layer
    };

    if (opc.collapsed === undefined) opc.collasped = true;
    L.control.layers(baseMaps, overlay, {collapsed: opc.collasped}).addTo(map);

    if (opc.pantalla_comp) map.addControl(fullscreen);

    map.addControl(zoom);
};