/**
 * Carga los overlays necesarios e inicia el mapa
 */
var cargaMapaYoverlays = function ()
{
    divisionEstadoOverlay = cargaDivision({tipo_region: 'estado'});
    divisionANPOverlay = cargaDivision({tipo_region: 'anp'});
    divisionMunicipioOverlay = cargaDivision({tipo_region: 'municipio'});

    cargaMapa('map', { "División estatal": divisionEstadoOverlay, "División por ANP": divisionANPOverlay, "División municipal": divisionMunicipioOverlay }, { pantalla_comp : false });
    divisionEstadoOverlay.addTo(map);  // carga de inicio la division estatal

    // Esto se tiene que solucionar de no cargarla desde un inicio
    divisionANPOverlay.addTo(map);
    map.removeLayer(divisionANPOverlay);
    divisionMunicipioOverlay.addTo(map);
    map.removeLayer(divisionMunicipioOverlay);
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

        d3.json('/topojson/' + opc.tipo_region + '.json', function (error, collection) {
            var bounds = d3.geo.bounds(topojson.feature(collection, collection.objects['collection']));
            var path = d3.geo.path().projection(projectPoint);

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
        var path = d3.geo.path().projection(projectPoint);

        var feature = g.selectAll('.region')
            .data(topojson.feature(collection, collection.objects['collection']).features)
            .enter()
            .append('path')
            .attr('class', 'region leaflet-clickable')
            .on('mouseover', function(d){
                nombreRegion(opciones.datos[opciones.estado_seleccionado].municipios[parseInt(d.properties.region_id)].properties);
            })
            .on('dblclick', function(d){
                seleccionaMunicipio(d.properties.region_id);
            })
            .each(function(d){
                if (opciones.datos[opciones.estado_seleccionado].municipios == undefined)
                    opciones.datos[opciones.estado_seleccionado].municipios = [];

                opciones.datos[opciones.estado_seleccionado].municipios[parseInt(d.properties.region_id)] = {};
                opciones.datos[opciones.estado_seleccionado].municipios[parseInt(d.properties.region_id)].properties = d.properties;
                opciones.datos[opciones.estado_seleccionado].municipios[parseInt(d.properties.region_id)].properties.layer = $(this);
                opciones.datos[opciones.estado_seleccionado].municipios[parseInt(d.properties.region_id)].properties.tipo_region = 'municipio';

                var bounds = d3.geo.bounds(d)
                opciones.datos[opciones.estado_seleccionado].municipios[parseInt(d.properties.region_id)].properties.bounds = [bounds[0].reverse(), bounds[1].reverse()];

                completaSelect(opciones.datos[opciones.estado_seleccionado].municipios[parseInt(d.properties.region_id)].properties);
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