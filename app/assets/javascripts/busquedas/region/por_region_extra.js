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
    $('#pagina').val(opciones.filtros.pagina);
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
    if (opciones.pixi.tiene_var_iniciales) limpiaMapa();  // Nos aseguramos que cada que escoja una region se limpien los registros
    opciones.pixi.tiene_var_iniciales = false;

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

$(document).ready(function(){
    /**
     * Cuando selecciona una especie
     */
    $('#contenedor_especies').on('click', '.boton-especie-registros', function(event){
        $('#especie-container-' + opciones.filtros.catalogo_id).removeClass('border-selected-especie');
        opciones.filtros.catalogo_id = $(this).attr('catalogo_id');
        opciones.filtros.especie_id = $(this).attr('catalogo_id');
        $('#especie-container-' + opciones.filtros.catalogo_id).addClass('border-selected-especie');
        cargaEjemplares('/explora-por-region/ejemplares?' + serializeParametros() + '&especie_id=' + opciones.filtros.catalogo_id);
        event.preventDefault();
    });

    /**
     * Para los filtros default: distribucion y riesgo
     */
    $('#busqueda_region').on('change', "#edo_cons, #dist, #grupo, #uso, #ambiente", function()
    {
        opciones.filtros.pagina = 1;
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
        cargaEspecies();
    });

    /**
     * Carga las anteriores especies
     */
    $('#contenedor_especies').on('click', '#carga-anteriores-especies, #carga-siguientes-especies', function(event){
        if (this.id == 'carga-anteriores-especies') opciones.filtros.pagina--;
        else opciones.filtros.pagina++;
        cargaEspecies();
        event.preventDefault();
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

    // Para inicializar la barra lateral del mapa
    L.control.sidebar('sidebar').addTo(map);
    control_capas = L.control.layers({}).addTo(map);
    opciones.filtros.pagina = 1;
    // Inicializa la carga inicial de las especies
    cargaEspecies();
    variablesIniciales();
    despliegaRegiones();
});