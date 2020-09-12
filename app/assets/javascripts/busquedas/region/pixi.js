snibLayer = L.layerGroup();
infoLayers = { 'totales': 0 };

/**
 * La simbologia dentro del mapa
 */
var leyenda = function()
{
    var snibControl = L.control.layers({}, {}, {collapsed: true, position: 'bottomright'}).addTo(map);

    snibControl.addOverlay(snibLayer,
        '<b>Ejemplares del SNIB</b><br />(museos, colectas y proyectos) <sub>' + infoLayers["totales"] + '</sub>'
    );

    if(infoLayers[1] !== undefined)
    {
        snibControl.addOverlay(infoLayers[1]["layer"],
        '<i class="fa fa-map-marker div-icon-snib"></i>Especímenes en colecciones <sub>' + infoLayers[1]["totales"] + '</sub>'
        );
    }

    if(infoLayers[2] !== undefined)
    {
        snibControl.addOverlay(infoLayers[2]["layer"],
            '<span aria-hidden="true" class="feather-ev-icon div-icon-snib"></span>Observaciones de aVerAves <sub>' + infoLayers[2]["totales"] + '</sub>'
        );
    }

    if(infoLayers[3] !== undefined)
    {
        snibControl.addOverlay(infoLayers[3]["layer"],
            '<span aria-hidden="true" class="bone-ev-icon div-icon-snib"></span>Fósiles <sub>' + infoLayers[3]["totales"] + '</sub>'
        );
    }

    if(infoLayers[4] !== undefined)
    {
        snib_control.addOverlay(infoLayers[4]["layer"],
            '<i class="fa fa-map-flag div-icon-snib"></i>Localidad no de campo <sub>' + infoLayers[4]["totales"] + '</sub>'
        );
    }

    if(infoLayers[5] !== undefined)
    {
        snib_control.addOverlay(infoLayers[5]["layer"],
            '<i class="div-icon-snib"></i>Naturalista <sub>' + infoLayers[5]["totales"] + '</sub>'
        );
    }
};

/**
 * Carga todos los registros del SNIB en una misma integracion
 */
var cargaRegistros = function(url)
{
    loader = new PIXI.Loader();
    loader
        /*.add('plane', '/imagenes/app/mapa/plane.png')
        .add('focusPlane', '/imagenes/app/mapa/focus-plane.png')
        .add('circle', '/imagenes/app/mapa/circle.png')
        .add('focusCircle', '/imagenes/app/mapa/focus-circle.png')
        .add('bicycle', '/imagenes/app/mapa/bicycle.png')
        .add('focusBicycle', '/imagenes/app/mapa/focus-bicycle.png');*/
        .add('defaultMarker', '/imagenes/app/mapa/default-marker.png')
        .add('defaultMarkerFocus', '/imagenes/app/mapa/default-marker-focus.png');
        //document.addEventListener("DOMContentLoaded", function() {
        loader.load(function(loader, resources) {
            
            textures = [resources.defaultMarker.texture];
            focusTextures = [resources.defaultMarkerFocus.texture];

            //textures = [resources.plane.texture, resources.circle.texture, resources.bicycle.texture];
            //focusTextures = [resources.focusPlane.texture, resources.focusCircle.texture, resources.focusBicycle.texture];
            legend = document.querySelector('div.legend.geometry');
            legendContent = legend.querySelector('.content');

            getJSON(url, function(markers) {

                if (markers["estatus"])
                {
                    //var colecciones = [1,2,3,4,5];
                    var colecciones = [5];
                    colecciones.forEach(function(coleccion){
                        if(markers["resultados"][coleccion] !== undefined && markers["resultados"][coleccion][0] !== undefined) 
                            cualColeccion(markers["resultados"][coleccion], coleccion);
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
    //});
};

/**
 * Carga ellayer de acuerdo a la coleccion especificada
 * @param {*} markers 
 * @param {*} coleccion 
 */
var cualColeccion = function(markers, coleccion)
{        
    var pixiLayer = (function() {
        var firstDraw = true;
        var prevZoom;
        var markerSprites = [];
        var frame = null;
        var focus = null;
        var pixiContainer = new PIXI.Container();
        var doubleBuffering = /iPad|iPhone|iPod/.test(navigator.userAgent) && !window.MSStream;
        
        return L.pixiOverlay(function(utils) {
            var zoom = utils.getMap().getZoom();
            if (frame) {
                cancelAnimationFrame(frame);
                frame = null;
            }
            var container = utils.getContainer();
            var renderer = utils.getRenderer();
            var project = utils.latLngToLayerPoint;
            var scale = utils.getScale();
            var invScale = 1 / scale;
            
            if (firstDraw) {
                prevZoom = zoom;
                markers.forEach(function(marker) {
                    var coords = project([marker[1], marker[0]]);
                    //var markerSprite = new PIXI.Sprite(textures[marker[3]]);
                    //markerSprite.textureIndex = marker[3];
                    var markerSprite = new PIXI.Sprite(textures[0]);
                    markerSprite.textureIndex = 0;
                    markerSprite.x0 = coords.x;
                    markerSprite.y0 = coords.y;
                    markerSprite.anchor.set(0.5, 0.5);
                    markerSprite.tint = 16771584; //8388608; // color de conabio en decimal
                    container.addChild(markerSprite);
                    markerSprites.push(markerSprite);
                    markerSprite.legend = marker[2];
                });

                var quadTrees = {};
                for (var z = map.getMinZoom(); z <= map.getMaxZoom(); z++) {
                    var rInit = ((z <= 7) ? 10 : 24) / utils.getScale(z);
                    quadTrees[z] = window.solveCollision(markerSprites, {r0: rInit, zoom: z});
                }

                function findMarker(ll) {
                    var layerPoint = project(ll);
                    var quadTree = quadTrees[utils.getMap().getZoom()];
                    var marker;
                    var rMax = quadTree.rMax;
                    var found = false;
                    quadTree.visit(function(quad, x1, y1, x2, y2) {
                        if (!quad.length) {
                            var dx = quad.data.x - layerPoint.x;
                            var dy = quad.data.y - layerPoint.y;
                            var r = quad.data.scale.x * 16;
                            if (dx * dx + dy * dy <= r * r) {
                                marker = quad.data;
                                found = true;
                            }
                        }
                        return found || x1 > layerPoint.x + rMax || x2 + rMax < layerPoint.x || y1 > layerPoint.y + rMax || y2 + rMax < layerPoint.y;
                    });
                    return marker;
                }
                
                map.on('click', function(e) {
                    var redraw = false;
                    if (focus) {
                        focus.texture = textures[focus.textureIndex];
                        focus = null;
                        L.DomUtil.addClass(legend, 'hide');
                        legendContent.innerHTML = '';
                        redraw = true;
                    }
                    
                    var marker = findMarker(e.latlng);
                    if (marker) {
                        marker.texture = focusTextures[marker.textureIndex];
                        focus = marker;
                        legendContent.innerHTML = marker.legend;
                        L.DomUtil.removeClass(legend, 'hide');
                        redraw = true;
                    }
                    if (redraw) utils.getRenderer().render(container);
                });
                
                var self = this;
                map.on('mousemove', L.Util.throttle(function(e) {
                    var marker = findMarker(e.latlng);
                    if (marker) {
                        L.DomUtil.addClass(self._container, 'leaflet-interactive');
                    } else {
                        L.DomUtil.removeClass(self._container, 'leaflet-interactive');
                    }
                }, 32));
            }
            
            if (firstDraw || prevZoom !== zoom) {
                markerSprites.forEach(function(markerSprite) {
                    var position = markerSprite.cache[zoom];
                    if (firstDraw) {
                        markerSprite.x = position.x;
                        markerSprite.y = position.y;
                        markerSprite.scale.set((position.r * scale < 16) ? position.r / 16 : invScale);
                    } else {
                        markerSprite.currentX = markerSprite.x;
                        markerSprite.currentY = markerSprite.y;
                        markerSprite.targetX = position.x;
                        markerSprite.targetY = position.y;
                        markerSprite.currentScale = markerSprite.scale.x;
                        markerSprite.targetScale = (position.r * scale < 16) ? position.r / 16 : invScale;
                    }
                });
            }

            var start = null;
            var delta = 250;
            function animate(timestamp) {
                var progress;
                if (start === null) start = timestamp;
                progress = timestamp - start;
                var lambda = progress / delta;
                if (lambda > 1) lambda = 1;
                lambda = lambda * (0.4 + lambda * (2.2 + lambda * -1.6));
                markerSprites.forEach(function(markerSprite) {
                    markerSprite.x = markerSprite.currentX + lambda * (markerSprite.targetX - markerSprite.currentX);
                    markerSprite.y = markerSprite.currentY + lambda * (markerSprite.targetY - markerSprite.currentY);
                    markerSprite.scale.set(markerSprite.currentScale + lambda * (markerSprite.targetScale - markerSprite.currentScale));
                });
                renderer.render(container);
                if (progress < delta) {
                frame = requestAnimationFrame(animate);
                }
            }
            if (!firstDraw && prevZoom !== zoom) {
                frame = requestAnimationFrame(animate);
            }
            firstDraw = false;
            prevZoom = zoom;
            renderer.render(container);
        }, pixiContainer, {
            doubleBuffering: doubleBuffering,
            destroyInteractionManager: true
        });
    })();

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