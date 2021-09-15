/**
 * Borra capas anteriores y carga las nuevas
 */
var cargaCapasGeoserver = function () {
  distribucionLayer = undefined;
  borraCapasAnterioresGeoserver();
  capaDistribucionGeoserver();
};

/**
 * Borra capas anteriores
 */
var borraCapasAnterioresGeoserver = function () {
  if (distribucionLayer == undefined) return;
  if (map.hasLayer(distribucionLayer)) {
    map.removeControl(geoserver_control);
    map.removeLayer(distribucionLayer);
  }
};

/**
 * Crear y carga la capa de distribucion
 */
var capaDistribucionGeoserver = function () {
  var primer_layer = false;
  distribucionLayer = L.layerGroup([], { zIndex: 100 });
  geoserver_control = L.control
    .layers({}, {}, { collapsed: true, position: "bottomleft" })
    .addTo(map);

  $.each(opciones.geodatos.geoserver_urls, function (index, geo) {
    window[geo.datos.layers] = L.tileLayer.wms(opciones.geodatos.geoserver_url, {
      layers: geo.datos.layers,
      format: "image/png",
      transparent: true,
      opacity: 0.7,
      zIndex: 4,
    });

    distribucionLayer.addLayer(window[geo.datos.layers]);

    if (!primer_layer) {
      map.addLayer(window[geo.datos.layers]);
      primer_layer = true;
    }

    geoserver_control.addOverlay(
      window[geo.datos.layers],
      geo.datos.autor + " " + geo.datos.anio
    );
  });

  tituloControlLayerGeoserver();
};

/**
 * Pone el titulo en el control del layer, esto para darle formato y quede visible sin pasarle el mouse
 */
var tituloControlLayerGeoserver = function () {
  $(".leaflet-control-layers:nth-child(1) a").remove();
  $(".leaflet-control-layers:nth-child(1)").prepend(
    '<div class="text-center m-2"><span class="font-weight-bold mr-2">Mapas de distribución</span><sub>' +
      opciones.geodatos.geoserver_urls.length +
      "</sub><div>"
  );
};
