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
            var grupos_orden = [resp.resultados[5],resp.resultados[1],resp.resultados[9],resp.resultados[0],resp.resultados[6],resp.resultados[4], resp.resultados[7],resp.resultados[3],resp.resultados[2],resp.resultados[8]];
            $.each(grupos_orden, function(index, prop){
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
                '<span>' + taxon.nombre_comun + '</span><br />' +
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

/**
 * Pone los municipios correspondientes, selecciona el valor y carga la region
 * @param valor
 */
var seleccionaEstado = function(region_id)
{
    if (region_id == '')
    {
        $('#region_municipio').empty().append('<option value>- - - - - - - -</option>').prop('disabled', true);

    } else {
        var region_id = parseInt(region_id);
        $('#region_estado').val(region_id);
        $('#region_municipio').empty().append('<option value>- - - Escoge un municipio - - -</option>');
        $('#region_municipio').prop('disabled', false).attr('parent_id', region_id);

        cargaRegion(opciones.datos[region_id].properties);
    }
};

var nombreRegion = function(region_id)
{
    var name = opciones.datos[region_id].properties.nombre_region;
    $('#contenedor-nombre-region').html(name);
};

/**
 * Rellena las opciones de estado y municipio
 * @param prop
 */
var completaSelect = function(prop)
{
    $('#region_' + prop.tipo_region).append('<option value="' + prop.region_id +'" bounds="[[' + prop.bounds[0] + '],[' + prop.bounds[1] + ']]" region_id_se="' + prop.region_id + '">' + prop.nombre_region + '</option>');
};