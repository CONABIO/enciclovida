$(document).ready(function(){

    /**
     * Cuando selecciona un grupo de los grupos icónicos
     */
    $('#contenedor_grupos').on('click', '.grupo_id', function(){
        opciones.grupo_seleccionado = $(this).attr('grupo');
        opciones.pagina_especies = 1;
        opciones.reino_seleccionado = $(this).attr('reino');
        cargaEspecies();
    });

    /**
     * Cuando selecciona una especie
     */
    $('#contenedor_especies').on('click', '.especie_id', function(){
        cargaRegistros($(this).attr('snib_url'));
        opciones.taxon_seleccionado.id = $(this).attr('especie_id');
        opciones.taxon_seleccionado.nombre_comun = $(this).siblings('.result-nombre-container').find('span')[0].innerText;
        opciones.taxon_seleccionado.nombre_cientifico = $(this).siblings('.result-nombre-container').find('i')[0].innerText;
    });

    /**
     *  Cuando selecciona un estado de la lista
     */
    $('#regiones').on('change', '#region_estado', function(){
        seleccionaEstado($(this).val());
    });

    /**
     * Cuando selecciona un municipio de la lista
     */
    $('#regiones').on('change', '#region_municipio', function(){
        seleccionaMunicipio($(this).val());
    });

    /**
     * Para los filtros default: distribucion y riesgo
     */
    $('#b_avanzada').on('change', ".checkbox input", function()
    {
        opciones.pagina_especies = 1;
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
    $('#carga_mas_especies').on('click', function(){
        opciones.pagina_especies++;
        cargaEspecies();
        return false;
    });

    /**
     * Cuando autocompleta por nombre cientifico o comun
     */
    $('#especies').on('keyup', '#nombre', function(){
        opciones.pagina_especies = 1;
        cargaEspecies();
    });

    /**
     * Para que aparezca la barra del scroll en las especies
     */
    $(window).load(function()
    {
        $("html,body").animate({scrollTop: 122}, 1000);
    });
});

