/**
 * Devuelve los parametros de acuerdo a los filtros, grupo, region y paginado y los refleja en la URL
 * @param prop, parametros adicionales
 * @returns {string}
 */
var cambiaURLParametros = function()
{
    var params = serializeParametros();
    var url = new URL(window.location.href);
    var url_parametros = url.origin + url.pathname + '?' + params + url.hash
    history.replaceState({}, '', url_parametros)
};

/**
 * Asigna los filtros iniciales de acuerdo a los parametros de la pagina
 */
var asignaFiltros = function(filtros)
{
    // Escogio de grupo iconico
    /*if (filtros.id != undefined && filtros.nombre == undefined)
    {
        $('#id_gi_' + filtros.id).prop('checked', true);
        $('#id').val(filtros.id);
    } else if (filtros.id != undefined && filtros.nombre != undefined) {  // escogio un nombre
        $('#id').val(filtros.id);
        $('#nombre').val(filtros.nombre);
    } else if (filtros.nombre != undefined){  // Solo escribio pero no escogio nombre
        por_nombre();
        $('#nombre').val(filtros.nombre);
    }*/
};

/**
 * Serializa los parametros de acuerdo a los filtros y quita los vacios
 */
var serializeParametros = function()
{
    return $("#busqueda_region input, #busqueda_region select").filter(function () {
        return !!this.value;
    }).serialize();
};

/**
 * Consulta el servicio nodejs para sacar el listado de especies por region
 */
var cargaEspecies = function()
{
    cambiaURLParametros();
    $.ajax({
        url: '/explora-por-region/especies',
        method: 'GET',
        data: serializeParametros()
    }).done(function(html) {
        $('#contenedor_especies').empty().html(html);
        ponTamaño();

    }).fail(function() {
        console.log('Hubo un fallo al cargar la lista de especies');
    });
};

/**
 * Asigna algunos valores antes de cargar la region con topojson
 * @param prop
 */
var seleccionaRegion = function(prop)
{
    if ($('#region_id').val() == prop.region_id) return;
    $('#region_id').val(prop.region_id);
    $('#nombre_region').val(prop.nombre_region);
    $('#tipo_region').val(prop.tipo_region.toLowerCase());

    opciones.filtros.pagina = 1;
    $('#pagina').val(opciones.filtros.pagina);

    map.flyToBounds(prop.bounds);
    cargaEspecies();
    colapsaBarra();  // colapsa la barrar lateral, para mayor comodidad
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
/*var dameEjemplaresSnib = function(datos)
{
    opciones.especie_id = datos.id;
    opciones.nombre_comun = datos.nombre_comun;
    opciones.nombre_cientifico = datos.nombre_cientifico;
    $('#especie_id').attr('value', datos.id);
    cargaEjemplaresSnib('/especies/' + datos.id + '/ejemplares-snib.json?mapa=1');
    colapsaBarra();
};*/

$(document).ready(function(){
    /**
     * Cuando selecciona una especie
     */
    $('#contenedor_especies').on('click', '.boton-especie-registros', function(){
        cargaEjemplares('/explora-por-region/ejemplares?' + serializeParametros().replace("&especie_id=", "") + '&especie_id=' + $(this).attr('catalogo_id'));
        opciones.especie_id = $(this).attr('especie_id');
        //opciones.nombre_comun = $(this).attr('nombre_comun');
        //opciones.nombre_cientifico = $(this).attr('nombre_cientifico');
        return false;
    });

    /**
     * Para los filtros default: distribucion y riesgo
     */
    $('#busqueda_region').on('change', "#edo_cons, #dist, #grupo, #uso, #ambiente", function()
    {
        opciones.filtros.pagina = 1;
        $('#pagina').val(opciones.filtros.pagina);
        cargaEspecies();
    });

    /**
     * Para cuando se escoge un grupo en la busqueda por region
     */
    $('#busqueda_region').on('change', "input:radio", function()
    {
        // El ID del grupo iconico
        var id_gi = $(this).val();
        $('#especie_id').val(id_gi);
        $('#nivel').val('=');
    
        // Para asignar la categoria de acuerdo al grupo
        switch(id_gi) {
            case '22653':
            case '22655':
            case '22647':
            case '22654':
            case '213482':
            case '22987':
            case '22651':
            case '22650':
            case '66500':
            case '16912':
            case '40672':
            case '56646':
            case '40658':
            case '66499':
            case '129550':
            case '40659':
            case '40657':
                $('#cat').val('7100');
                break;
            default:
                $('#cat').val('7000');
        }

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
     * Carga las siguientes especies
     */
    $('#contenedor_especies').on('click', '#carga-siguientes-especies', function(){
        opciones.filtros.pagina++;
        $('#pagina').val(opciones.filtros.pagina);
        cargaEspecies();
        return false;
    });

    // Para asignar el redis adecuado de acuerdo a la caja de texto
    $('#busqueda_region').on('focus', '#nombre_especie, #nombre_region', function() {
        if ($(this).attr('soulmate') == "true") return;
        $(this).attr('soulmate', 'true');
        
        if (this.id == 'nombre_especie') soulmateAsigna('busqueda_region', this.id);
        else soulmateRegionAsigna(this.id);
    });

    // Cuando le da clic en recargar
    $('#sidebar').on('click','#recarga-tab',function () {
        window.location.href = '/explora-por-region';
    });

    // Inicializa la carga inicial de las especies
    // Para inicializar la barra lateral del mapa
    L.control.sidebar('sidebar').addTo(map);
    control_capas = L.control.layers({}).addTo(map);
    opciones.filtros.pagina = 1;
    asignaFiltros(opciones.filtros);
    cargaEspecies();
    variablesIniciales();
    despliegaRegiones();
});