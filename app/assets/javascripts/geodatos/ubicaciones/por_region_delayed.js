$(document).ready(function(){

    $('#contenedor_grupos').on('click', '.grupo_id', function(){
        grupo_id_seleccionado = $(this).attr('grupo_id');
        pagina_especies = 1;
        cargaEspecies();
    });

    $('#contenedor_especies').on('click', '.especie_id', function(){
        cargaRegistros($(this).attr('snib_url'));
        taxon["id"] = $(this).attr('especie_id');
        taxon["nombre_comun"] = $(this).siblings('.result-nombre-container').find('b')[0].innerText;
        taxon["nombre_cientifico"] = $(this).siblings('.result-nombre-container').find('b')[1].innerText;
        return false;
    });

    /**
     *  Para escoger con las listas
     */
    $('#regiones').on('change', '#region_estado', function(){
        if ($(this).val() == '')
        {
            $('#region_municipio').empty().append('<option value>- - - - - - - -</option>').prop('disabled', true);
            $('#region_anp').empty().append('<option value>- - - - - - - -</option>').prop('disabled', true);

        } else {
            $('#region_municipio').empty().append('<option value>- - - Escoge un municipio - - -</option>');
            $('#region_municipio').prop('disabled', false).attr('parent_id', $(this).val());

            var prop = {};
            prop.bounds = eval($('option:selected', this).attr('bounds'));
            prop.layer = layer_obj['estado'][$(this).val()];
            prop.region_id = $(this).val();
            prop.tipo_region = 'estado';
            prop.region_id_se = $(this).val();
            cargaRegion(prop);
        }
    });

    $('#regiones').on('change', '#region_municipio', function(){
        if ($(this).val() == '')
            console.log('esta vacio');
        //$('#region_anp').empty().append('<option value>- - - - - - - -</option>').prop('disabled', true);

        else {
            var prop = {};
            prop.bounds = eval($('option:selected', this).attr('bounds'));
            prop.layer = layer_obj['municipio'][$(this).val()];
            prop.region_id = $(this).val();
            prop.parent_id = CORRESP[$(this).attr('parent_id')];
            prop.tipo_region = 'municipio';
            prop.region_id_se = $('option:selected', this).attr('region_id_se');
            cargaRegion(prop);
        }

    });

    /*$( "#toggle-ba-icon" ).click(function() {
        $( "#toggle-ba-content" ).slideToggle( "fast", function() {});
    });*/

    $('#b_avanzada').on('change', ".checkbox input", function()
    {
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
                data: parametrosCargaEspecies({correo: correo})
            }).done(function(resp) {
                if (resp.estatus == 1)
                {
                    $('#estatus_descargar_taxa').empty().html('!La petición se envió correctamente!. Se te enviará un correo con los resultados que seleccionaste.');
                } else
                    $('#estatus_descargar_taxa').empty().html('Lo sentimos no se pudo procesar tu petición, asegurate de haber anotado correctamente tu correo e inténtalo de nuevo.');

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
        pagina_especies++;
        cargaEspecies();
        return false;
    });

    $('#especies').on('keyup', '#nombre', function(){
        pagina_especies = 1;
        cargaEspecies();
    });

});