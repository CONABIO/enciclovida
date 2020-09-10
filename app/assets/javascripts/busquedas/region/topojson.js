/**
 * Carga los overlays necesarios e inicia el mapa
 */
var cargaMapaYoverlays = function ()
{
    divisionEstadoOverlay = cargaDivision({tipo_region: 'estado'});
    //divisionANPOverlay = cargaDivision({tipo_region: 'anp'});
    //divisionMunicipioOverlay = cargaDivision({tipo_region: 'municipio'});

    cargaMapa('map', { overlay: { "División estatal": divisionEstadoOverlay }, pantalla_comp : true, collapsed: true, position: 'topright' });
    //cargaMapa('map', { overlay: { "División estatal": divisionEstadoOverlay, "División por ANP": divisionANPOverlay, "División municipal": divisionMunicipioOverlay }, pantalla_comp : true, collapsed: true, position: 'topright' });
    divisionEstadoOverlay.addTo(map);  // carga de inicio la division estatal

    // Esto se tiene que solucionar de no cargarla desde un inicio
    /*divisionANPOverlay.addTo(map);
    map.removeLayer(divisionANPOverlay);
    divisionMunicipioOverlay.addTo(map);
    map.removeLayer(divisionMunicipioOverlay);*/


    /* EXPERIMENTAL */
    var loader = new PIXI.loaders.Loader();
loader
    .add('plane', '/imagenes/app/mapa/plane.png')
    .add('focusPlane', '/imagenes/app/mapa/focus-plane.png')
    .add('circle', '/imagenes/app/mapa/circle.png')
    .add('focusCircle', '/imagenes/app/mapa/focus-circle.png')
    .add('bicycle', '/imagenes/app/mapa/bicycle.png')
    .add('focusBicycle', '/imagenes/app/mapa/focus-bicycle.png');
    //.add('markerIcon', '/imagenes/app/mapa/marker-icon.png')
    //.add('markerIconFocus', '/imagenes/app/mapa/marker-icon-focus.png');
document.addEventListener("DOMContentLoaded", function() {
    loader.load(function(loader, resources) {
        //var textures = [resources.markerIcon.texture];
        //var focusTextures = [resources.markerIconFocus.texture];

        var textures = [resources.plane.texture, resources.circle.texture, resources.bicycle.texture];
		var focusTextures = [resources.focusPlane.texture, resources.focusCircle.texture, resources.focusBicycle.texture];
        
        getJSON('/ejemplo-corto.json', function(markers) {
            /*map = L.map('map').setView([46.953387, 2.892341], 6);
            L.tileLayer('//stamen-tiles-{s}.a.ssl.fastly.net/toner/{z}/{x}/{y}.png', {
                subdomains: 'abcd',
                attribution: 'Map tiles by <a href="http://stamen.com">Stamen Design</a>, under <a href="http://creativecommons.org/licenses/by/3.0">CC BY 3.0</a>. Data by <a href="http://openstreetmap.org">OpenStreetMap</a>, under <a href="http://www.openstreetmap.org/copyright">ODbL</a>.',
                minZoom: 6,
                maxZoom: 18
            }).addTo(map);
            map.attributionControl.setPosition('bottomleft');
            map.zoomControl.setPosition('bottomright');*/
            
            var legend = document.querySelector('div.legend.geometry');
            var legendContent = legend.querySelector('.content');
            
            var pixiLayer = (function() {
                var firstDraw = true;
                var prevZoom;
                var markerSprites = [];
                var colorScale = d3.scaleLinear()
                    .domain([0, 50, 100])
                    .range(["#c6233c", "#ffd300", "#008000"]);

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
                            var coords = project([marker.latitude, marker.longitude]); //*
                            var index = Math.floor(Math.random() * textures.length);
                            var markerSprite = new PIXI.Sprite(textures[index]);
                            markerSprite.textureIndex = index;
                            markerSprite.x0 = coords.x;
                            markerSprite.y0 = coords.y;
                            markerSprite.anchor.set(0.5, 0.5);
                            //var tint = d3.color(colorScale(marker.avancement || Math.random() * 100)).rgb();
                            //console.log(256 * (tint.r * 256 + tint.g) + tint.b)
                            //markerSprite.tint = 256 * (tint.r * 256 + tint.g) + tint.b;
                            markerSprite.tint = 8388608; // color de conabio en decimal
                            container.addChild(markerSprite);
                            markerSprites.push(markerSprite);
                            //markerSprite.legend = marker.city || marker.label;
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

            pixiLayer.addTo(map);
        });
    });
});

};

/* EXPERIMENTAL */
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

/**
 * Carga la division estatal de un inicio
 */
var cargaDivision = function(opc)
{
    var divisionOverlay = L.d3SvgOverlay(function() {
        if ($('#svg-division-' + opc.tipo_region + ' g').length > 0) return;

        var svg = d3.select(map.getPanes().overlayPane).append('svg').attr('id', 'svg-division-' + opc.tipo_region);
        var g = svg.append('g').attr('class', 'leaflet-zoom-hide');
        
        d3.json('/topojson/' + opc.tipo_region + '.json', function (collection) {
            console.log('aqui')
            var bounds = d3.geoBounds(topojson.feature(collection, collection.objects['collection']));
            var path = d3.geoPath().projection(projectPoint);

            var feature = g.selectAll('.region')
                .data(topojson.feature(collection, collection.objects['collection']).features)
                .enter()
                .append('path')
                .attr('class', 'region leaflet-clickable')
                .attr('id', function(d){
                    return "path-" + opc.tipo_region + "-" + d.properties.region_id
                })
                .on('mouseover', function(d){
                    nombreRegion(d.properties);
                })
                .on('dblclick', function(d){
                    seleccionaRegion(d.properties);
                })
                .each(function(d){
                    // Asigna los valores la primera y unica vez que carga los estados
                    if (opciones.datos[opc.tipo_region] === undefined) opciones.datos[opc.tipo_region] = {};
                    opciones.datos[opc.tipo_region][d.properties.region_id] = {};
                    opciones.datos[opc.tipo_region][d.properties.region_id].properties = d.properties;
                });

            map.on('zoomend', reinicia);
            map.on('zoomstart', function(){muestraOcultaSvg();});
            reinicia(); // Lo inicializa

            // Reposiciona el svg si se realiza un zoom
            function reinicia()
            {
                var bottomLeft = projectPoint(bounds[0]);
                var topRight = projectPoint(bounds[1]);

                svg.attr('width', topRight[0] - bottomLeft[0])
                    .attr('height', bottomLeft[1] - topRight[1])
                    .style('margin-left', bottomLeft[0] + 'px')
                    .style('margin-top', topRight[1] + 'px');

                g.attr('transform', 'translate(' + -bottomLeft[0] + ',' + -topRight[1] + ')');
                feature.attr('d', path);
                muestraOcultaSvg(true);
            }
        });
    });

    divisionOverlay.on("add", function () {
        $('#svg-division-' + opc.tipo_region).show();
    });

    divisionOverlay.on("remove", function () {
        $('#svg-division-' + opc.tipo_region).hide();
    });

    return divisionOverlay;
};

/**
 * Carga todos los municipios de cierto estado
 */
var cargaDivisionMunicipal = function()
{
    var svg = d3.select(map.getPanes().overlayPane).append('svg').attr('id', 'svg-division-municipio');
    var g = svg.append('g').attr('class', 'leaflet-zoom-hide');

    d3.json('/topojson/estado_' + opciones.estado_seleccionado + '_division_municipal.json', function (error, collection) {
        var bounds = d3.geo.bounds(topojson.feature(collection, collection.objects['collection']));
        var path = d3.geoPath().projection(projectPoint);

        var feature = g.selectAll('.region')
            .data(topojson.feature(collection, collection.objects['collection']).features)
            .enter()
            .append('path')
            .attr('class', 'region leaflet-clickable')
            .on('mouseover', function(d){
                nombreRegion(opciones.datos[opciones.estado_seleccionado].municipios[d.properties.region_id].properties);
            })
            .on('dblclick', function(d){
                seleccionaMunicipio(d.properties.region_id);
            })
            .each(function(d){
                if (opciones.datos[opciones.estado_seleccionado].municipios == undefined)
                    opciones.datos[opciones.estado_seleccionado].municipios = [];

                opciones.datos[opciones.estado_seleccionado].municipios[d.properties.region_id] = {};
                opciones.datos[opciones.estado_seleccionado].municipios[d.properties.region_id].properties = d.properties;
                opciones.datos[opciones.estado_seleccionado].municipios[d.properties.region_id].properties.layer = $(this);
                opciones.datos[opciones.estado_seleccionado].municipios[d.properties.region_id].properties.tipo_region = 'municipio';

                completaSelect(opciones.datos[opciones.estado_seleccionado].municipios[d.properties.region_id].properties);
            });

        map.on('zoomend', reinicia);
        map.on('zoomstart', function(){muestraOcultaSvg();});

        // Reposition the SVG to cover the features.
        function reinicia()
        {
            var bottomLeft = projectPoint(bounds[0]);
            var topRight = projectPoint(bounds[1]);

            svg.attr('width', topRight[0] - bottomLeft[0])
                .attr('height', bottomLeft[1] - topRight[1])
                .style('margin-left', bottomLeft[0] + 'px')
                .style('margin-top', topRight[1] + 'px');

            g.attr('transform', 'translate(' + -bottomLeft[0] + ',' + -topRight[1] + ')');
            feature.attr('d', path);
            muestraOcultaSvg(true);
        }
    });
};

/**
 * Habilita o deshabilitas las regiones para posteriormente cargar la indicada, viene del soulmate
 */
var administraRegiones = function (tipo, region_id)
{
    $('#region_id').attr('value', region_id);
    $('#tipo_region').val(tipo);

    switch(tipo)
    {
        case 'estado':
            if (map.hasLayer(divisionANPOverlay)) map.removeLayer(divisionANPOverlay);
            if (map.hasLayer(divisionMunicipioOverlay)) map.removeLayer(divisionMunicipioOverlay);
            if (!map.hasLayer(divisionEstadoOverlay)) map.addLayer(divisionEstadoOverlay);
            break;
        case 'municipio':
            if (map.hasLayer(divisionANPOverlay)) map.removeLayer(divisionANPOverlay);
            if (map.hasLayer(divisionEstadoOverlay)) map.removeLayer(divisionEstadoOverlay);
            if (!map.hasLayer(divisionMunicipioOverlay)) map.addLayer(divisionMunicipioOverlay);
            break;
        case 'anp':
            if (map.hasLayer(divisionEstadoOverlay)) map.removeLayer(divisionEstadoOverlay);
            if (map.hasLayer(divisionMunicipioOverlay)) map.removeLayer(divisionMunicipioOverlay);
            if (!map.hasLayer(divisionANPOverlay)) map.addLayer(divisionANPOverlay);
            break;
    }

    cargaEspecies();
    cargaRegion(opciones.datos[tipo][region_id].properties);
};

/**
 * Carga una sola region en especifico, municipios o estado; reutilizando esta funcion
 se necesita un obj con prop: region_id, centroide, tipo_region, parent_id
 * @param prop
 */
var cargaRegion = function(prop)
{
    quitaSeleccionRegion();
    map.flyToBounds(prop.bounds);
    //borraEjemplaresAnterioresSnib();

    $('#path-' + prop.tipo.toLowerCase() + '-' + prop.region_id).attr('class', 'selecciona-region');
};

/**
 * Sirve para que cuando se vuelva a activar la capa no se quede con alguna region seleccionada
 */
var quitaSeleccionRegion = function ()
{
    $('#svg-division-estado .selecciona-region').attr('class', 'region');
    $('#svg-division-municipio .selecciona-region').attr('class', 'region');
    $('#svg-division-anp .selecciona-region').attr('class', 'region');
};

/**
 * Para cuando se hace una animacion con flyTo, los svgs de estatal o municipal o region sola
 * @param caso
 */
var muestraOcultaSvg = function(caso)
{
    if (caso)
    {
        $('#svg-division-estado').css('visibility', 'visible');
        $('#svg-division-anp').css('visibility', 'visible');
        $('#svg-division-municipio').css('visibility', 'visible');
        $('#svg-region').css('visibility', 'visible');
    } else {
        $('#svg-division-estado').css('visibility', 'hidden');
        $('#svg-division-municipio').css('visibility', 'hidden');
        $('#svg-division-anp').css('visibility', 'hidden');
        $('#svg-region').css('visibility', 'hidden');
    }
};

/**
 * Hace la projecccion de los puntos en D3 cuando se hace un zoom
 * @param x
 * @returns {*[]}
 */
var projectPoint = function(x)
{
    var point = map.latLngToLayerPoint(new L.LatLng(x[1], x[0]));
    return [point.x, point.y];
};

/**
 * Funciones propias de topojson
 * @param opts
 */
function addTopoData(opts){
    if (opts.clean) opts.layer.clearLayers();

    opts.layer.addData(opts.topojson);
    opts.layer.addTo(map);

    if (opts.fillColor == undefined) opts.fillColor = '#d8d8d8';
    if (opts.color == undefined) opts.color = '#808080';
    handleLayer(opts);
}

function handleLayer(opts){
    opts.layer.setStyle({
        fillColor : opts.fillColor,
        fillOpacity:.5,
        color: opts.color,
        weight:1,
        opacity:.5
    });
    opts.layer.on({
        mouseover : enterLayer,
        mouseout: leaveLayer
    });
}

function enterLayer(){
    this.bringToFront();
    this.setStyle({
        weight:3,
        opacity:.5
    });
}

function leaveLayer(){
    this.bringToBack();
    this.setStyle({
        weight:1,
        opacity:.5
    });
}