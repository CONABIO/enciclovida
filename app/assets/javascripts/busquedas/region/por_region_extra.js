/**
 * Devuelve los parametros de acuerdo a los filtros, grupo, region y paginado
 * @param prop, parametros adicionales
 * @returns {string}
 */
var parametros = function(prop)
{
    var params_generales = { region_id: $('#region_id').val(), pagina: opciones.filtro.pagina, especie_id: $('#espcie_id').val() };

    if (prop != undefined)
        params_generales = Object.assign({},params_generales, prop);

    return $('#b_region').serialize() + '&' + $.param(params_generales);
};

/**
 * Consulta el servicio nodejs para sacar el listado de especies por region
 */
var cargaEspecies = function()
{
    $.ajax({
        url: '/explora-por-region/especies',
        method: 'GET',
        data: $('#busqueda_region').serialize()
    }).done(function(html) {
        if (opciones.filtros.pagina == 1)
            $('#contenedor_especies').empty().html(html);
        else
            $('#contenedor_especies_itera').empty().html(html);


    }).fail(function() {
        console.log('Hubo un fallo al cargar la lista de especies');
    });
};

/**
 * Asigna algunos valores antes de cargar la region con topojson
 * @param valor
 */
var seleccionaRegion = function(prop)
{
    var region_id = parseInt(prop.region_id);
    $('#region_id').val(region_id);
    $('#region').val(prop.nombre_region);
    $('#tipo_region').val(prop.tipo.toLowerCase());

    //$('#svg-division-municipal').remove();

    opciones.filtros.pagina = 1;
    $('#pagina').val(opciones.filtros.pagina);

    cargaEspecies();
    cargaRegion(opciones.datos[prop.tipo.toLowerCase()][region_id].properties);
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
    $('#contenedor-subtitulo-busqueda-region').html(prop.nombre_region);
};

/**
 * Para cuando eliga alguna opcion se oculte automáticamente la barra y pueda ver el resultado
 */
var colapsaBarra  =function()
{
    $('#sidebar').addClass('collapsed');
    $('#sidebar .sidebar-tabs li').removeClass('active');
};

/**
 * Asigna los datos del taxon para posteriormente ocuparlos en los ejemplares
 */
var dameEjemplaresSnib = function(datos)
{
    opciones.especie_id = datos.id;
    opciones.nombre_comun = datos.nombre_comun;
    opciones.nombre_cientifico = datos.nombre_cientifico;
    $('#especie_id').attr('value', datos.id);
    cargaEjemplaresSnib('/especies/' + datos.id + '/ejemplares-snib.json?mapa=1');
    colapsaBarra();
};

$(document).ready(function(){
    /**
     * Cuando selecciona una especie
     */
    $('#contenedor_especies').on('click', '.boton-especie-registros', function(){
        cargaEjemplaresSnib($(this).attr('snib_registros'));
        opciones.especie_id = $(this).attr('especie_id');
        opciones.nombre_comun = $(this).attr('nombre_comun');
        opciones.nombre_cientifico = $(this).attr('nombre_cientifico');
        return false;
    });

    /**
     * Para los filtros default: distribucion y riesgo
     */
    $('#busqueda_region').on('change', "input", function()
    {
        opciones.filtros.pagina = 1;
        $('#pagina').val(opciones.filtros.pagina);
        cargaEspecies();
    });

    /**
     * Para enviar la descarga o que se envie correo
     */
    $(document).on('keyup', '#correo', function(){
        if( !correoValido($(this).val()) )
        {
            $(this).parent().addClass("has-error");
            $(this).parent().removeClass("has-success");

            $(this).siblings("span:first").addClass("glyphicon-remove");
            $(this).siblings("span:first").removeClass("glyphicon-ok");
            $('#boton_enviar_descarga').attr('disabled', 'disabled')
        } else {
            $(this).parent().removeClass("has-error");
            $(this).parent().addClass("has-success");
            $(this).siblings("span:first").addClass("glyphicon-ok");
            $(this).siblings("span:first").removeClass("glyphicon-remove");
            $('#boton_enviar_descarga').removeAttr('disabled')
        }
    });

    /**
     * Para validar una ultima vez cuando paso la validacion del boton
     */
    $(document).on('click', '#boton_enviar_descarga', function(){
        var correo = $('#correo').val();

        if(correoValido(correo))
        {
            $.ajax({
                url: '/explora-por-region/descarga-taxa',
                type: 'GET',
                dataType: "json",
                data: parametros({correo: correo})
            }).done(function(resp) {
                if (resp.estatus == 1)
                {
                    $('#estatus_descargar_taxa').empty().html('!La petición se envió correctamente!. Se te enviará un correo con los resultados que seleccionaste.');
                } else
                    $('#estatus_descargar_taxa').empty().html(resp.msg);

            }).fail(function(){
                $('#estatus_descargar_taxa').empty().html('Lo sentimos no se pudo procesar tu petición, asegurate de haber anotado correctamente tu correo e inténtalo de nuevo.');
            });

        } else
            $('#estatus_descargar_taxa').empty().html('El correo no parece válido, por favor verifica.');
    });

    /**
     * Esta funcion se sustituirá por el scrolling
     */
    $('#contenedor_especies').on('click', '#carga-mas-especies', function(){
        opciones.filtros.pagina++;
        $('#pagina').val(opciones.filtros.pagina);
        cargaEspecies();
        return false;
    });

    // Para inicializar la barra lateral del mapa
    L.control.sidebar('sidebar').addTo(map);

    // Para asignar el redis adecuado de acuerdo a la caja de texto
    $('#busqueda-region-tab').on('focus', '#nombre, #region', function() {
        if ($(this).attr('soulmate') == "true") return;

        var tipo_busqueda = $(this).attr('id');

        if (tipo_busqueda == 'nombre') soulmateAsigna('busqueda_region', this.id);
        else soulmateRegionAsigna(this.id);
    });

    // Cuando le da clic en recargar
    $('#sidebar').on('click','#recarga-tab',function () {
        location.reload();
        return false;
    });

    // Inicializa la carga inicial de las especies
    opciones.filtros.pagina = 1;
    cargaEspecies();
});