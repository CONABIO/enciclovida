/**
 * Para ponerle comas a los numeros en el conteo de la simbologia
 * @param {*} number
 */
var numberWithDelimiter = function (number) {
  return number.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");
};

/**
 * Variables para poder cargar la visualizacion con PIXI
 */
var variablesIniciales = function () {
  // El obejto inical de PIXI
  loader = new PIXI.loaders.Loader();
  loader
    .add("colectas", "/imagenes/app/mapa/colectas.png")
    .add("averaves", "/imagenes/app/mapa/averaves.png")
    .add("fosiles", "/imagenes/app/mapa/fosiles.png")
    .add("nodecampo", "/imagenes/app/mapa/nodecampo.png")
    .add("naturalista", "/imagenes/app/mapa/naturalista.png");

  // variable global para no repetir js ni eventos
  opciones.pixi = {};
  opciones.pixi.tiene_var_iniciales = false;
};

/**
 * Escala del marcador de acuerdo al zoom
 * @param {*} invScale
 * @param {*} zoom
 */
var markerScale = function (zoom) {
  switch (zoom) {
    case 5:
      scale = 9;
      break;
    case 6:
      scale = 4.5;
      break;
    case 7:
      scale = 2.5;
      break;
    case 8:
      scale = 1.5;
      break;
    case 9:
      scale = .7;
      break;
    case 10:
      scale = .35;
      break;
    case 11:
      scale = .15;
      break;
    case 12:
      scale = 0.09;
      break;
    case 13:
      scale = 0.43;
      break;
    case 14:
      scale = 0.21;
      break;
    case 15:
      scale = 0.11;
      break;
    case 16:
      scale = 0.06;
      break;
    case 17:
      scale = 0.03;
      break;
    case 18:
      scale = 0.015;
      break;
  }

  return scale;
};

/**
 * Hace limpieza de las variables para poder desplegar distintas visualizaciones
 */
var configuraVariables = function () {
  if (opciones.pixi.tiene_var_iniciales) limpiaMapa();
  inicializaVariables();
  opciones.pixi.tiene_var_iniciales = true;
  opciones.pixi.popup = undefined;
};

/**
 * Limpia e inicializa las variables de los layer y el control
 */
var inicializaVariables = function () {
  snibLayer = L.layerGroup(); // Layer papa que tiene las capas
  infoLayers = { totales: 0 }; // Tiene los conteos por layer
  snibControl = L.control.layers(
    {},
    {},
    { collapsed: true, position: "bottomleft" }
  );
};

/**
 * Limpia los layer y el control
 */
var limpiaMapa = function () {
  if (opciones.pixi.popup) {
    opciones.pixi.popup.removeFrom(map);
    $("#ejemplar_id").val("");
    $("#latitud").val("");
    $("#longitud").val("");
    cambiaURLParametros();
  }

  map.removeLayer(snibLayer);
  map.removeControl(snibControl);
};

/**
 * La simbologia personalizada dentro del mapa
 */
var leyenda = function () {
  if (infoLayers[2] !== undefined) {
    snibControl.addOverlay(
      infoLayers[2]["layer"],
      "<img src='/imagenes/app/mapa/averaves.png'> aVerAves <span class='badge badge-pill badge-info br-badge'>" +
        numberWithDelimiter(infoLayers[2]["totales"]) +
        "</span>"
    );
  }

  if (infoLayers[5] !== undefined) {
    snibControl.addOverlay(
      infoLayers[5]["layer"],
      "<img src='/imagenes/app/mapa/naturalista.png'> Naturalista <span class='badge badge-pill badge-info br-badge'>" +
        numberWithDelimiter(infoLayers[5]["totales"]) +
        "</span>"
    );
  }

  if (infoLayers[1] !== undefined) {
    snibControl.addOverlay(
      infoLayers[1]["layer"],
      "<img src='/imagenes/app/mapa/colectas.png'> Colecciones <span class='badge badge-pill badge-info br-badge'>" +
        numberWithDelimiter(infoLayers[1]["totales"]) +
        "</span>"
    );
  }

  if (infoLayers[3] !== undefined) {
    snibControl.addOverlay(
      infoLayers[3]["layer"],
      "<img src='/imagenes/app/mapa/fosiles.png'> Fósiles <span class='badge badge-pill badge-info br-badge'>" +
        numberWithDelimiter(infoLayers[3]["totales"]) +
        "</span>"
    );
  }

  if (infoLayers[4] !== undefined) {
    snibControl.addOverlay(
      infoLayers[4]["layer"],
      "<img src='/imagenes/app/mapa/nodecampo.png'> Localidad no de campo <span class='badge badge-pill badge-info br-badge'>" +
        numberWithDelimiter(infoLayers[4]["totales"]) +
        "</span>"
    );
  }
};

/**
 * Regresa la informacion del ejemplar
 */
var createPopup = function (ejemplar_id) {
  if (ejemplar_id == undefined) var ej_id = opciones.filtros.marker[2];
  else var ej_id = ejemplar_id;

  getJSON("/explora-por-region/ejemplar?ejemplar_id=" + ej_id, function (resp) {
    if (resp.estatus) {
      var data = resp.resultados[0];
      var info = infoPopup(data);

      opciones.pixi.popup = L.popup({ offset: L.point(0, 0) })
        .setLatLng([data.latitud, data.longitud])
        .setContent(info)
        .openOn(map);

      // Asigna en la url los datos del punto seleccionado
      $("#ejemplar_id").val(ej_id);
      cambiaURLParametros();
    }
  });
};

var infoPopup = function (data) {
  contenido = "<strong>Localidad:</strong> " + data.localidad + "<br />";
  contenido += "<strong>Municipio: </strong>" + data.municipiomapa + "<br />";
  contenido += "<strong>Estado: </strong>" + data.estadomapa + "<br />";
  contenido += "<strong>País: </strong>" + data.paismapa + "<br />";
  contenido += "<strong>Fecha: </strong>" + data.fechacolecta + "<br />";
  contenido += "<strong>Colector: </strong>" + data.colector + "<br />";
  contenido += "<strong>Colección: </strong>" + data.coleccion + "<br />";
  contenido += "<strong>Institución: </strong>" + data.institucion + "<br />";
  contenido +=
    "<strong>País de la colección: </strong>" + data.paiscoleccion + "<br />";

  if (data.proyecto.length > 0 && data.urlproyecto.length > 0)
    contenido +=
      "<strong>Proyecto: </strong><a href='" +
      data.urlproyecto +
      "' target='_blank'>" +
      data.proyecto +
      "</a><br />";

  contenido +=
    "<strong>Más información: </strong><a href='" +
    data.urlejemplar +
    "' target='_blank'>consultar</a><br />";

  //Para enviar un comentario acerca de un ejemplar en particular
  contenido +=
    "<strong>¿Tienes un comentario?: </strong><a href='/especies/" +
    opciones.filtros.especie_id_focus +
    "/comentarios/new?proveedor_id=" +
    data.idejemplar +
    "&tipo_proveedor=6' target='_blank'>redactar</a><br />";

  return "<dl class='dl-horizontal'>" + contenido + "</dl>";
};

/**
 * Inicializando una función que posteriormente debe ir aquí (esta función tiene que ver con el cambio de tamaño de la cortina de resultados de especies en las busquedas por región)
 */
var goState = function(){};

/**
 * Carga todos los registros del SNIB en una misma integracion
 */
var cargaEjemplares = function (url) {
    /* Para mostrarle al usuario un loading y q espere en lo que se cargan los registros*/
    $('#loading').toggleClass('invisible');
    configuraVariables();
    loader.load(function (loader, resources) {
        textures = [
            null,
            resources.colectas.texture,
            resources.averaves.texture,
            resources.fosiles.texture,
            resources.nodecampo.texture,
            resources.naturalista.texture,
        ];
        getJSON(url, function (markers) {
            if (markers["estatus"]) {
                // Quitando los eventos para no repetirlos
                //map.off("click");
                //map.off("mousemove");

                var colecciones = [1, 2, 3, 4, 5];
                tree_complete = [];
                tree = [];

                colecciones.forEach(function (coleccion) {
                    if (
                        markers["resultados"][coleccion] !== undefined &&
                        markers["resultados"][coleccion][0] !== undefined
                    ) {
                        porColeccion(markers["resultados"][coleccion], coleccion);
                    }
                });

                if (infoLayers["totales"] > 0) {
                    snibLayer.addTo(map);
                    snibControl.addTo(map);
                    reordenaControles();
                    leyenda();
                    $(
                        "<p><b>Ejemplares del SNIB</b> <span class='badge badge-pill badge-info br-badge'>" +
                        numberWithDelimiter(infoLayers["totales"]) +
                        "</span><br />(colectas, ciencia ciudadana, <br />museos, proyectos)</p>"
                    ).insertBefore(
                        $(snibControl.getContainer()).find(
                            ".leaflet-control-layers-separator"
                        )
                    );
                    $(snibControl.getContainer())
                        .find(".leaflet-control-layers-separator")
                        .show();
                    $(snibControl.getContainer())
                        .find(".leaflet-control-layers-toggle")
                        .css("background-color", "#333333");
                    /* Quitando el loading ua vez q ya fueron pintados los registros*/
                    $('#loading').toggleClass('invisible');
                    goState(1);
		                /*Nos movemos un cuarto del mapa a la derecha*/
		                map.panBy(new L.Point(-(map.getSize().x*0.25), 0), {animate: false});
                }
            }
        });
    });
};

/**
 * Carga ellayer de acuerdo a la coleccion especificada
 * @param {*} markers
 * @param {*} coleccion
 */
var porColeccion = function (markers, coleccion) {
  var easing = BezierEasing(0, 0, 0.25, 1);
  var pixiLayer = (function () {
    var zoomChangeTs = null;
    var pixiContainer = new PIXI.Container();
    var innerContainer = new PIXI.particles.ParticleContainer(markers.length, {
      vertices: true,
    });
    innerContainer.texture = textures[coleccion];
    innerContainer.baseTexture = textures[coleccion].baseTexture;
    innerContainer.anchor = { x: 0.5, y: 1 };

    pixiContainer.addChild(innerContainer);
    var doubleBuffering =
      /iPad|iPhone|iPod/.test(navigator.userAgent) && !window.MSStream;
    var initialScale;

    return L.pixiOverlay(
      function (utils, event) {
        var zoom = utils.getMap().getZoom();
        var container = utils.getContainer();
        var renderer = utils.getRenderer();
        var project = utils.latLngToLayerPoint;
        var getScale = utils.getScale;
        var invScale = 1 / getScale();

        if (event.type === "add") {
          initialScale = markerScale(zoom);
          innerContainer.localScale = initialScale;

          markers.forEach(function (marker) {
            var coords = project([marker[1], marker[0]]);

            innerContainer.addChild({
              x: coords.x,
              y: coords.y,
              id: marker[2],
            });
          });

          tree_complete = tree_complete.concat(innerContainer.children);
          tree = d3
            .quadtree()
            .addAll(tree_complete.map((p) => [p.x, p.y, p.id]));

          if (opciones.pixi.click == undefined) {
            map.on("click", function (e) {
              var m = findMarker(e);
              if (m) {
                opciones.filtros.marker = m;
                createPopup();
              }
            });
            opciones.pixi.click = true;
          }

          if (opciones.pixi.mousemove == undefined) {
            map.on(
              "mousemove",
              L.Util.throttle(function (e) {
                var marker = findMarker(e);
                if (marker) {
                  $("#map canvas").addClass("leaflet-interactive");
                  opciones.pixi.marker = true;
                } else {
                  $("#map canvas").removeClass("leaflet-interactive");
                  opciones.pixi.marker = false;
                }
              }, 32)
            );
            opciones.pixi.mousemove = true;
          }
        }

        if (event.type === "zoomanim") {
          var targetZoom = event.zoom;
          zoomChangeTs = 0;
          var targetScale = markerScale(targetZoom);
          innerContainer.currentScale = innerContainer.localScale;
          innerContainer.targetScale = targetScale;
          return;
        }

        if (event.type === "redraw") {
          var delta = event.delta;
          if (zoomChangeTs !== null) {
            var duration = 17;
            zoomChangeTs += delta;
            var lambda = zoomChangeTs / duration;
            if (lambda > 1) {
              lambda = 1;
              zoomChangeTs = null;
            }
            lambda = easing(lambda);
            innerContainer.localScale =
              innerContainer.currentScale +
              lambda *
                (innerContainer.targetScale - innerContainer.currentScale);
          } else {
            return;
          }
        }

        function findMarker(e) {
          var coords = project(e.latlng);
          return tree.find(coords.x, coords.y, markerScale(event.zoom) * 10);
        }

        renderer.render(container);
      },
      pixiContainer,
      {
        doubleBuffering: doubleBuffering,
        destroyInteractionManager: true,
      }
    );
  })();

  var ticker = new PIXI.ticker.Ticker();
  ticker.add(function (delta) {
    pixiLayer.redraw({ type: "redraw", delta: delta });
  });
  map.on("zoomstart", function () {
    ticker.start();
  });
  map.on("zoomend", function () {
    ticker.stop();
  });
  map.on("zoomanim", pixiLayer.redraw, pixiLayer);

  snibLayer.addLayer(pixiLayer);
  infoLayers[coleccion] = {};
  infoLayers[coleccion]["layer"] = pixiLayer;
  infoLayers[coleccion]["totales"] = markers.length;
  infoLayers["totales"] += infoLayers[coleccion]["totales"];
};

var getJSON = function (url, successHandler, errorHandler) {
  var xhr =
    typeof XMLHttpRequest != "undefined"
      ? new XMLHttpRequest()
      : new ActiveXObject("Microsoft.XMLHTTP");
  xhr.open("get", url, true);
  xhr.onreadystatechange = function () {
    var status;
    var data;
    if (xhr.readyState == 4) {
      status = xhr.status;
      if (status == 200) {
        data = JSON.parse(xhr.responseText);
        successHandler && successHandler(data);
      } else {
        errorHandler && errorHandler(status);
      }
    }
  };
  xhr.send();
};
