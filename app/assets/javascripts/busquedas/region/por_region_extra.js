/**
 * Carga los grupos iconicos y su respectivo conteo
 * @param properties
 */
var cargaGrupos = function()
{
    $.ajax({
        url: '/explora-por-region/conteo-por-grupo',
        data: parametros()
    }).done(function(resp) {
        if (resp.estatus)
        {
            $('#contenedor_grupos').empty();
            $('#contenedor_especies').empty();
            var grupos_orden = [resp.resultados[5],resp.resultados[1],resp.resultados[9],resp.resultados[0],
                resp.resultados[6],resp.resultados[4], resp.resultados[7],resp.resultados[3],resp.resultados[2],resp.resultados[8]];
            $.each(grupos_orden, function(index, prop){
                $('#contenedor_grupos').append('<label><input type="radio" name="id"><span tooltip-title="' +
                    prop.grupo + '" class="'+  prop.icono+' grupo_id btn btn-xs btn-basica btn-title" grupo="'+prop.grupo+
                    '" reino="' + prop.reino + '"></span><sub grupo_id_badge="'+ prop.grupo +'">' + prop.total + '</sub></label>');
            });
        } else
            console.log('Falló el servicio de conteo del SNIB');

    }).fail(function() {
        console.log('Falló el servicio de conteo del SNIB');
    });
};

/**
 * Devuelve los parametros de acuerdo a los filtros, grupo, region y paginado
 * @param prop, parametros adicionales
 * @returns {string}
 */
var parametros = function(prop)
{
    var params_generales = { tipo_region: opciones.tipo_region_seleccionado, grupo: opciones.grupo_seleccionado, estado_id: opciones.estado_seleccionado,
        municipio_id: opciones.municipio_seleccionado, pagina: opciones.pagina_especies, nombre: $('#nombre').val() };

    if (prop != undefined)
        params_generales = Object.assign({},params_generales, prop);

    return $('#b_avanzada').serialize() + '&' + $.param(params_generales);
};

/**
 * Pregunta por los datos correspondientes a estas especies en nuestra base, todos deberian coincidir en teoria
 * ya que son ids de catalogos, a excepcion de los nuevos, ya que aún no se actualiza a la base centralizada
 */
var cargaEspecies = function()
{
    $.ajax({
        url: '/explora-por-region/especies-por-grupo',
        method: 'GET',
        data: parametros()
    }).done(function(resp) {
        if (resp.estatus)  // Para asignar los resultados con o sin filtros
        {
            if (opciones.pagina_especies == 1) $('#contenedor_especies').empty();
            $('#grupos').find("[grupo_id_badge='" + opciones.grupo_seleccionado + "']").text(resp.totales);

            $.each(resp.resultados, function(index, taxon){
                var url = dameUrlServicioSnibPorRegion({catalogo_id: taxon.catalogo_id, estado_id: opciones.estado_seleccionado,
                    municipio_id: opciones.municipio_seleccionado, snib_url: opciones.snib_url, reino: opciones.reino_seleccionado});
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
    $('#svg-division-municipal').remove();

    if (region_id == '')
    {
        $('#region_municipio').empty().append('<option value>- - - - - - - -</option>').prop('disabled', true);
        opciones.estado_seleccionado = null;
        opciones.tipo_region_seleccionado = null;
    } else {
        var region_id = parseInt(region_id);
        $('#region_estado').val(region_id);
        $('#region_municipio').empty().append('<option value>- - - Escoge un municipio - - -</option>');
        $('#region_municipio').prop('disabled', false).attr('parent_id', region_id);

        opciones.estado_seleccionado = region_id;
        opciones.municipio_seleccionado = null;
        opciones.tipo_region_seleccionado = 'estado';
        cargaRegion(opciones.datos[region_id].properties);
    }
};

/**
 * Pone los municipios correspondientes, selecciona el valor y carga la region
 * @param valor
 */
var seleccionaMunicipio = function(region_id)
{
    if (region_id == '')
    {
        opciones.municipio_seleccionado = null;
        opciones.tipo_region_seleccionado = 'estado';

    } else {
        var region_id = parseInt(region_id);
        $('#region_municipio').val(region_id);
        opciones.municipio_seleccionado = region_id;
        opciones.tipo_region_seleccionado = 'municipio';
        cargaRegion(opciones.datos[opciones.estado_seleccionado].municipios[region_id].properties);
    }
};

/**
 * El nombre de la region cuanso se pasa el mouse por encima
 * @param prop
 */
var nombreRegion = function(prop)
{
    $('#contenedor-nombre-region').html(prop.nombre_region);
};

/**
 * Rellena las opciones de estado y municipio
 * @param prop
 */
var completaSelect = function(prop)
{
    $('#region_' + prop.tipo_region).append("<option value='" + parseInt(prop.region_id) + "'>" + prop.nombre_region + '</option>');
};

/**
 * Devuelve la URL de las especies por region
 * @param prop
 * @returns {string}
 */
var dameUrlServicioSnibPorRegion = function(prop)
{
    prop.estado_id = opciones.correspondencia[prop.estado_id];

    var snib_url = prop.snib_url + '/' + prop.reino + '/' + prop.catalogo_id + '/' + prop.estado_id;

    if (prop.municipio_id != null && prop.municipio_id != '')
    {
        prop.municipio_id = ('00'+prop.municipio_id).slice(-3);
        snib_url+= '/' + prop.municipio_id;
    }

    snib_url+= '?apiKey=enciclovida';
    return snib_url;
};