$(document).ready(function () {
  // Inicia el mapa
  cargaMapa("map", {
    pantalla_comp: true,
    collapsed: true,
    position: "topright",
  });

  variablesIniciales();
  opciones.filtros = {};
  cargaEjemplares(
    "/explora-por-region/ejemplares?" + "&catalogo_id=" + opciones.catalogo_id
  );

  // Para cargar las capas del geoserver
  if (opciones.geodatos.geoserver_url !== undefined)
    cargaCapasGeoserver();
});
