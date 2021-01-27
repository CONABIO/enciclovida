/**
 * Inicializa el mapa
 * @param id
 * @param overlay
 */
var cargaMapa = function (id, opc) {
  // Por si viene vacia la variable opc
  if (opc === undefined) opc = {};
  if (opc.position == undefined) opc.position = "topleft";

  // Google Hybrid
  var GHM_layer = L.tileLayer(
    "https://{s}.google.com/vt/lyrs=y&x={x}&y={y}&z={z}",
    {
      subdomains: ["mt0", "mt1", "mt2", "mt3"],
      zIndex: 1,
      noWrap: true,
    }
  );

  /*
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
    
    // Wikimedia Maps
    var WM_layer = L.tileLayer('https://maps.wikimedia.org/osm-intl/{z}/{x}/{y}.png',{
        zIndex: 1,
        noWrap: true
    });
    */

  var place = [23.79162789, -102.04376221];

  map = L.map(id, {
    zoomControl: false,
    doubleClickZoom: false,
    minZoom: 5,
    layers: [
      // Existe un bug poniendo primero los layers de google
      //OSM_layer,
      GHM_layer,
      //WM_layer,
      //GTM_layer,
    ],
  });

  var zoom = L.control.zoom({
    zoomInTitle: "Acercarse",
    zoomOutTitle: "Alejarse",
    position: opc.position,
  });

  // https://github.com/brunob/leaflet.fullscreen
  var fullscreen = L.control.fullscreen({
    position: opc.position,
    title: "Pantalla completa",
    titleCancel: "Salir de pantalla completa",
  });

  map.setView(place, 4); // Default place and zoom

  // Para poner las capas iniciales de los mapas
  var baseMaps = {
    "Vista Híbrida": GHM_layer,
    /*"Open Street Maps": OSM_layer,
        "Vista de terreno": GTM_layer,
        "Mapas de Wikipedia": WM_layer*/
  };

  if (opc.collapsed === undefined) opc.collasped = true;
  if (opc.overlay !== undefined)
    L.control
      .layers(baseMaps, opc.overlay, { collapsed: opc.collapsed })
      .addTo(map);

  if (opc.fullscreen === undefined) opc.fullscreen = true;
  if (opc.fullscreen) map.addControl(fullscreen);

  if (opc.zoom === undefined) opc.zoom = true;
  if (opc.zoom) map.addControl(zoom);

  if (opc.hash === undefined) opc.hash = false;
  if (opc.hash) var hash = new L.Hash(map);

  //Para asegurarnos que siempre se genere el mapa con el mínimo markup posible
  ponTamaño();
};
