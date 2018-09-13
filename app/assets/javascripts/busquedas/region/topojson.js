/**
 * Carga la division estatal de un inicio
 */
var cargaDivisionEstatal = function()
{
    var svg = d3.select(map.getPanes().overlayPane).append('svg').attr('id', 'svg-division-estatal');
    var g = svg.append('g').attr('class', 'leaflet-zoom-hide');

    d3.json('/topojson/estado.json', function (error, collection) {
        var bounds = d3.geo.bounds(topojson.feature(collection, collection.objects['collection']));
        var path = d3.geo.path().projection(projectPoint);

        var feature = g.selectAll('.region')
            .data(topojson.feature(collection, collection.objects['collection']).features)
            .enter()
            .append('path')
            .attr('class', 'region leaflet-clickable')
            .on('mouseover', function(d){
                nombreRegion(opciones.datos[d.properties.region_id].properties);
            })
            .on('dblclick', function(d){
                seleccionaEstado(d.properties.region_id);
            })
            .each(function(d){
                // Asigna los valores la primera y unica vez que carga los estados
                opciones.datos[d.properties.region_id] = {};
                opciones.datos[d.properties.region_id].properties = d.properties;
                opciones.datos[d.properties.region_id].properties.layer = $(this);
                opciones.datos[d.properties.region_id].properties.tipo_region = 'estado';

                var bounds = d3.geo.bounds(d)
                opciones.datos[d.properties.region_id].properties.bounds = [bounds[0].reverse(), bounds[1].reverse()];

                completaSelect(opciones.datos[d.properties.region_id].properties);
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
};

/**
 * Carga todos los municipios de cierto estado
 */
var cargaDivisionMunicipal = function()
{
    var svg = d3.select(map.getPanes().overlayPane).append('svg').attr('id', 'svg-division-municipal');
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
 * Carga una sola region en especifico, municipios o estado; reutilizando esta funcion
 se necesita un obj con prop: region_id, centroide, tipo_region, parent_id
 * @param prop
 */
var cargaRegion = function(prop)
{
    switch(prop.tipo_region)
    {
        case 'estado':
            cargaDivisionMunicipal();
            break;
        case 'municipio':
            break;
    }

    map.flyToBounds(prop.bounds);
    cargaGrupos();
    borraEjemplaresAnterioresSnib();
    $('#svg-division-estatal .selecciona-region').attr('class', 'region');
    $('#svg-division-municipal .selecciona-region').attr('class', 'region');
    prop.layer.attr('class', 'selecciona-region');
};

/**
 * Para cuando se hace una animacion con flyTo, los svgs de estatal o municipal o region sola
 * @param caso
 */
var muestraOcultaSvg = function(caso)
{
    if (caso)
    {
        $('#svg-division-estatal').css('visibility', 'visible');
        $('#svg-division-municipal').css('visibility', 'visible');
        $('#svg-region').css('visibility', 'visible');
    } else {
        $('#svg-division-estatal').css('visibility', 'hidden');
        $('#svg-division-municipal').css('visibility', 'hidden');
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