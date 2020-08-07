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
    var OSM_layer = L.tileLayer('https://{s}.tile.osm.org/{z}/{x}/{y}.png',{
        subdomains:['a','b','c'],
        zIndex: 1,
        noWrap: true
    });

    // Google terrain map layer
    var GTM_layer = L.tileLayer('https://{s}.google.com/vt/lyrs=p&x={x}&y={y}&z={z}',{
        subdomains:['mt0','mt1','mt2','mt3'],
        zIndex: 1,
        noWrap: true
    });
    // Google Hybrid
    var GHM_layer = L.tileLayer('https://{s}.google.com/vt/lyrs=y&x={x}&y={y}&z={z}',{
        subdomains:['mt0','mt1','mt2','mt3'],
        zIndex: 1,
        noWrap: true
    });
    // Wikimedia Maps
    var WM_layer = L.tileLayer('https://maps.wikimedia.org/osm-intl/{z}/{x}/{y}.png',{
        zIndex: 1,
        noWrap: true
    });

    var place = [23.79162789, -102.04376221];

    map = L.map(id, {
        zoomControl: false,
        doubleClickZoom: false,
        minZoom: 4,
        layers: [     // Existe un bug poniendo primero los layes de google
            //OSM_layer,
            GHM_layer,
            //WM_layer,
            //GTM_layer,
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
    /*
    var baseMaps = {
        "Vista Híbrida": GHM_layer,
        "Open Street Maps": OSM_layer,
        "Vista de terreno": GTM_layer,
        "Mapas de Wikipedia": WM_layer
    };

    if (opc.collapsed === undefined) opc.collasped = true;
    L.control.layers(baseMaps, overlay, {collapsed: opc.collasped}).addTo(map);

    if (opc.pantalla_comp) map.addControl(fullscreen);

    map.addControl(zoom);

    */
    //Para asegurarnos que siempre se genere el mapa con el mínimo markup posible
    ponTamaño();

};