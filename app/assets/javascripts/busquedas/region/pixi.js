/**
 * Variables para poder cargar la visualizacion con PIXI
 */
var variablesIniciales = function()
{
    // El obejto inical de PIXI
    loader = new PIXI.loaders.Loader();
    loader
        .add('colectas', '/imagenes/app/mapa/colectas.png')
        .add('averaves', '/imagenes/app/mapa/averaves.png')
        .add('fosiles', '/imagenes/app/mapa/fosiles.png')
        .add('nodecampo', '/imagenes/app/mapa/nodecampo.png')
        .add('naturalista', '/imagenes/app/mapa/naturalista.png');
    ya_cargo = false;
};

/**
 * Hace limpieza de las variables para poder desplegar distintas visualizaciones
 */
var configuraVariables = function()
{
    if (ya_cargo) limpiaMapa();
    inicializaVariables();
    ya_cargo = true;
};

/**
 * Limpia e inicializa las variables de los layer y el control
 */
var inicializaVariables = function()
{
    snibLayer = L.layerGroup();  // Layer papa que tiene las capas
    infoLayers = { 'totales': 0 };  // Tiene los conteos por layer
    snibControl = L.control.layers({}, {}, {collapsed: true, position: 'bottomright'}).addTo(map);
};

/**
 * Limpia los layer y el control
 */
var limpiaMapa = function()
{
    map.removeLayer(snibLayer);
    map.removeControl(snibControl);
};

/**
 * La simbologia personalizada dentro del mapa
 */
var leyenda = function()
{
    snibControl.addOverlay(snibLayer,
        '<b>Ejemplares del SNIB</b><br />(museos, colectas, proyectos) <sub>' + infoLayers["totales"] + '</sub>'
    );

    if(infoLayers[2] !== undefined)
    {
        snibControl.addOverlay(infoLayers[2]["layer"],
            '<img src="/imagenes/app/mapa/averaves.png"> Observaciones de aVerAves <sub>' + infoLayers[2]["totales"] + '</sub>'
        );
    }

    if(infoLayers[5] !== undefined)
    {
        snibControl.addOverlay(infoLayers[5]["layer"],
            '<img src="/imagenes/app/mapa/naturalista.png"> Naturalista <sub>' + infoLayers[5]["totales"] + '</sub>'
        );
    }

    if(infoLayers[1] !== undefined)
    {
        snibControl.addOverlay(infoLayers[1]["layer"],
        '<img src="/imagenes/app/mapa/colectas.png"> Especímenes en colecciones <sub>' + infoLayers[1]["totales"] + '</sub>'
        );
    }

    if(infoLayers[3] !== undefined)
    {
        snibControl.addOverlay(infoLayers[3]["layer"],
            '<img src="/imagenes/app/mapa/fosiles.png"> Fósiles <sub>' + infoLayers[3]["totales"] + '</sub>'
        );
    }

    if(infoLayers[4] !== undefined)
    {
        snibControl.addOverlay(infoLayers[4]["layer"],
            '<img src="/imagenes/app/mapa/nodecampo.png"> Localidad no de campo <sub>' + infoLayers[4]["totales"] + '</sub>'
        );
    }
};

/**
 * Carga todos los registros del SNIB en una misma integracion
 */
var cargaEjemplares = function(url)
{
    configuraVariables();
    loader.load(function(loader, resources) {
        textures = [null, resources.colectas.texture, resources.averaves.texture, resources.fosiles.texture, resources.nodecampo.texture, resources.naturalista.texture];
        getJSON(url, function(markers) {
            if (markers["estatus"])
            {
                var colecciones = [1,2,3,4,5];
                //var colecciones = [1];
                colecciones.forEach(function(coleccion){
                    if(markers["resultados"][coleccion] !== undefined && markers["resultados"][coleccion][0] !== undefined) 
                        porColeccion(markers["resultados"][coleccion], coleccion);
                        //cualColeccion([[-98.98, 21.2078056, 6142080], [-98.98, 21.21, 6142081]], coleccion);
                });   

                if (infoLayers["totales"] > 0)
                {
                    snibLayer.addTo(map);
                    leyenda();
                    $('div.leaflet-control-layers label div input').first().remove();
                } 
            }    
        });
    });
};

var borraEjemeplares = function()
{
    this.loader.destroy();
};

/**
 * Carga ellayer de acuerdo a la coleccion especificada
 * @param {*} markers 
 * @param {*} coleccion 
 */
var porColeccion = function(markers, coleccion)
{        
    var easing = BezierEasing(0, 0, 0.25, 1);
    var pixiLayer = (function() {
        var zoomChangeTs = null;
        var pixiContainer = new PIXI.Container();
        var innerContainer = new PIXI.particles.ParticleContainer(markers.length, {vertices: true});
        innerContainer.texture = textures[coleccion];
        innerContainer.baseTexture = textures[coleccion].baseTexture;
        innerContainer.anchor = {x: 0.5, y: .5};

        pixiContainer.addChild(innerContainer);
        var doubleBuffering = /iPad|iPhone|iPod/.test(navigator.userAgent) && !window.MSStream;
        //var initialScale;
        
        return L.pixiOverlay(function(utils, event) {
            var zoom = utils.getMap().getZoom();
            var container = utils.getContainer();
            var renderer = utils.getRenderer();
            var project = utils.latLngToLayerPoint;
            var getScale = utils.getScale;
            var invScale = 1 / getScale();

            if (event.type === 'add') {
                var origin = project([(14.54 + 32.38) / 2, (-117.67 + -85.29) / 2]);
                innerContainer.x = origin.x;
                innerContainer.y = origin.y;
                var localScale = .6 / getScale(zoom);
                innerContainer.localScale = localScale;

                markers.forEach(function(marker) {
                    var coords = project([marker[1], marker[0]]);

                    innerContainer.addChild({
                        x: coords.x - origin.x,
                        y: coords.y - origin.y,
                        id: marker[2],
                    });
                });

                tree = d3.quadtree().addAll(innerContainer.children.map(p => [p.x, p.y, p.id]));
					map.on('click', function(e) {
							findMarker(e)
				});
            }

            if (event.type === 'zoomanim') {
                var targetZoom = event.zoom;
                if (targetZoom >= 5 || zoom >= 5) {
                    zoomChangeTs = 0;
                    var targetScale = targetZoom >= 5 ? .8 / getScale(event.zoom) : .8 / getScale(event.zoom);
                    innerContainer.currentScale = innerContainer.localScale;
                    innerContainer.targetScale = targetScale;
                }
                return;
            }

            if (event.type === 'redraw') {
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
                  innerContainer.localScale = innerContainer.currentScale + lambda * (innerContainer.targetScale - innerContainer.currentScale);
                } else {return;}
            }

            function findMarker(e){
                var origin = project([(14.54 + 32.38) / 2, (-117.67 + -85.29) / 2]);
                var coords = project(e.latlng);
                console.log(1 / getScale(event.zoom))
                console.log(tree.find(coords.x - origin.x, coords.y - origin.y, 1 / getScale(event.zoom)))
            }

            renderer.render(container);
        }, pixiContainer, {
            doubleBuffering: doubleBuffering,
            destroyInteractionManager: true
        });
    })();

    var ticker = new PIXI.ticker.Ticker();
    ticker.add(function(delta) {
        pixiLayer.redraw({type: 'redraw', delta: delta});
    });
    map.on('zoomstart', function() {
        ticker.start();
    });
    map.on('zoomend', function() {
        ticker.stop();
    });
    map.on('zoomanim', pixiLayer.redraw, pixiLayer);
    
    snibLayer.addLayer(pixiLayer);
    infoLayers[coleccion] = {}
    infoLayers[coleccion]["layer"] = pixiLayer;
    infoLayers[coleccion]["totales"] = markers.length;
    infoLayers["totales"] += infoLayers[coleccion]["totales"];
};

var getJSON = function(url, successHandler, errorHandler) {
    var xhr = typeof XMLHttpRequest != 'undefined'
        ? new XMLHttpRequest()
        : new ActiveXObject('Microsoft.XMLHTTP');
    xhr.open('get', url, true);
    xhr.onreadystatechange = function() {
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