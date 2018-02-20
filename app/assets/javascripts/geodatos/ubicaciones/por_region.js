var cargaMapa = function (id)
{
    // El default de leaflet
    var OSM_layer = L.tileLayer('http://{s}.tile.osm.org/{z}/{x}/{y}.png',{
        zIndex: 1,
        noWrap: true
    });

    // Google terrain map layer
    var GTM_layer = L.tileLayer('http://{s}.google.com/vt/lyrs=p&x={x}&y={y}&z={z}',{
        subdomains:['mt0','mt1','mt2','mt3'],
        zIndex: 2,
        noWrap: true
    });
    // Google Hybrid
    var GHM_layer = L.tileLayer('http://{s}.google.com/vt/lyrs=y&x={x}&y={y}&z={z}',{
        subdomains:['mt0','mt1','mt2','mt3'],
        zIndex: 3,
        noWrap: true
    });

    var place = [23.79162789, -102.04376221];

    map = L.map(id, {
        zoomControl: false,
        doubleClickZoom: false,
        layers: [     // Existe un bug poniendo primero los layes de google
            OSM_layer,
            GTM_layer,
            GHM_layer
        ]
    });

    var zoom = L.control.zoom({
        zoomInTitle: 'Acercarse',
        zoomOutTitle: 'Alejarse'
    });

    // https://github.com/brunob/leaflet.fullscreen
    var fullscreen = L.control.fullscreen({
        position: 'topleft',
        title: 'Pantalla completa',
        titleCancel: 'Salir de pantalla completa'
    });

    map.addControl(zoom);
    map.addControl(fullscreen);

    map.setView(place, 5);  // Default place and zoom

    // Para poner las capas iniciales de los mapas
    var baseMaps = {
        "Open Street Maps": OSM_layer,
        "Vista de terreno": GTM_layer,
        "Vista Híbrida": GHM_layer
    };

    L.control.layers(baseMaps).addTo(map);
};

/**
 * Devuelve los parametros de acuerdo a los filtros, grupo, region y paginado
 * @param prop
 * @returns {string}
 */
var parametrosCargaEspecies = function(prop)
{
    if ($('#region_municipio').val() == '')
    {
        var region_id = CORRESP[$('option:selected', $('#region_estado')).val()];
        var parent_id = '';
    } else {
        var region_id = $('option:selected', $('#region_municipio')).val();
        var parent_id = CORRESP[$('#region_municipio').attr('parent_id')];
    }

    var params_generales = {grupo_id: grupo_id_seleccionado,
        region_id: region_id, parent_id: parent_id, pagina: pagina_especies, nombre: $('#nombre').val()};

    if (prop != undefined)
        params_generales = Object.assign({},params_generales, prop);

    return $('#b_avanzada').serialize() + '&' + $.param(params_generales);
};

var cargaGrupos = function(properties)
{
    if (properties.tipo_region == 'estado')
    {
        var region_id = CORRESP[properties.region_id];
        var parent_id = '';
    } else {
        var region_id = properties.region_id;
        var parent_id = properties.parent_id;
    }

    $.ajax({
        url: '/explora-por-region/conteo-por-grupo',
        data: {tipo_region: properties.tipo_region, region_id: region_id, parent_id: parent_id}
    }).done(function(resp) {
        if (resp.estatus)
        {
            $('#contenedor_grupos').empty();
            $('#contenedor_especies').empty();
            var lol = [resp.resultados[5],resp.resultados[1],resp.resultados[9],resp.resultados[0],resp.resultados[6],resp.resultados[7],resp.resultados[3],resp.resultados[2],resp.resultados[8]];
            $.each(lol, function(index, prop){
                $('#contenedor_grupos').append('<label><input type="radio" name="id"><span tooltip-title="' + prop.grupo + '" class="'+  prop.icono+' grupo_id btn btn-xs btn-basica btn-title" grupo_id="'+prop.grupo+'" reino="' + prop.reino + '"></span><sub grupo_id_badge="'+ prop.grupo +'">' + prop.total + '</sub></label>');
            });
        } else
            console.log('Falló el servicio de conteo del SNIB');

    }).fail(function() {
        console.log('Falló el servicio de conteo del SNIB');
    });
};

var cargaEspecies = function()
{
    // Pregunta por los datos correspondientes a estas especies en nuestra base, todos deberian coincidir en teoria ya que son ids de catalogos, a excepcion de los nuevos, ya que aún no se actualiza a la base centralizada
    $.ajax({
        url: '/explora-por-region/especies-por-grupo',
        method: 'GET',
        data: parametrosCargaEspecies()
    }).done(function(resp) {
        if (resp.estatus)  // Para asignar los resultados con o sin filtros
        {
            if (pagina_especies == 1) $('#contenedor_especies').empty();
            $('#grupos').find("[grupo_id_badge='" + grupo_id_seleccionado + "']").text(resp.totales);

            $.each(resp.resultados, function(index, taxon){
                var url = dameUrlServicioSnib({catalogo_id: taxon.catalogo_id, tipo_region_se: tipo_region_se, region_id_se: region_id_se, geoportal_url: geoportal_url, reino: $('#grupos').find("[grupo_id='" + grupo_id_seleccionado + "']").attr('reino')});
                if (url == undefined) return;

                // Las que no tiene imagen se le pega la fuente
                if (taxon.foto == null)
                    var recurso = '<i class="ev1-ev-icon"></i>';
                else
                    var recurso = '<img src="' + taxon.foto + '"/>';

                // Las que no tienen nombre común se le pondra vacío
                if (taxon.nombre_comun == null) taxon.nombre_comun = '';

                $('#contenedor_especies').append('<div class="result-img-container">' +
                '<a class="especie_id" snib_url="' + url + '" especie_id="' + taxon.id + '">' + recurso + '<sub>' + taxon.nregistros + '</sub></a>' +
                '<div class="result-nombre-container">' +
                taxon.nombre_comun + '<br />' +
                '<a href="/especies/'+taxon.id+'" target="_blank"><i>' + taxon.nombre_cientifico + '</i></a>' +
                '</div>' +
                '</div>');
            });
        } else
            console.log(resp.msg);

    }).fail(function() {
        console.log('Falló la carga de especies de enciclovida');
    });
};

// Rellena las opciones de region-estado
var completaSelect = function(prop)
{
    if (layer_obj[prop.tipo_region] == undefined) layer_obj[prop.tipo_region] = {};
    layer_obj[prop.tipo_region][prop.region_id] = prop.layer;

    $('#region_' + prop.tipo_region).append('<option value="' + prop.region_id +'" bounds="[[' + prop.bounds[0] + '],[' + prop.bounds[1] + ']]" region_id_se="' + prop.region_id_se + '">' + prop.nombre_region + '</option>');
};