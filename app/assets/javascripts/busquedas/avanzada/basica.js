$(document).ready(function(){
    $('#pestañas').tabs(); // Inicia los tabs
    scrolling_page("#resultados-0", settings.nop, settings.url);  // Inicia el scrolling

    /**
     *  Carga los taxones de la categoria dada
     **/
    $("#pestañas").on('click', '.tab_por_categoria', function (){
        var id_por_categoria = parseInt($(this).attr('categoria_taxonomica_id'));
        var url = $(this).attr('url');

        if (id_por_categoria == 0)  // tab default
        {
            settings.offset = offset[0];
            settings.cat = 0;
            settings.url = settings.url_original;

            datos_descarga.url = settings.url_original;
            datos_descarga.cuantos = settings.totales;

        } else {
            $.each(POR_CATEGORIA, function (index, value) {
                if (value.categoria_taxonomica_id == id_por_categoria) {

                    if (offset[value.categoria_taxonomica_id] == undefined)
                    {
                        offset[value.categoria_taxonomica_id] = 2;
                        settings.offset = offset[value.categoria_taxonomica_id];
                    } else
                        settings.offset = offset[value.categoria_taxonomica_id];

                    settings.cat = value.categoria_taxonomica_id;
                    settings.url = value.url;

                    datos_descarga.url = value.url;
                    datos_descarga.cuantos = value.cuantos;
                }
            });
        }

        // Carga el contenido cuando le da clic en una pestaña por primera vez
        if ($("#resultados-" + settings.cat).html().length == 0)
            $("#resultados-" + settings.cat).load(url);
    });

    // Para validar una ultima vez cuando paso la validacion del boton
    $('#modal-descarga-lista').on('click', '#boton-descarga-lista', function(){
        var url_xlsx = datos_descarga.url.replace("resultados?", "resultados.xlsx?");
        var correo = $('#correo-lista').val();

        if(correoValido(correo))
        {
            $.ajax({
                url: url_xlsx + "&correo=" + correo,
                type: 'GET',
                dataType: "json"
            }).done(function(resp) {
                $('#modal-descarga-lista').modal('toggle');

                if (resp.estatus == 1)
                    $('#notice-avanzada').empty().html('!La petición se envió correctamente!. Se te enviará un correo con los resultados de tu búsqueda!').removeClass('d-none').slideDown(600);
                else
                    $('#notice-avanzada').empty().html('Lo sentimos no se pudo procesar tu petición, asegurate de haber anotado correctamente tu correo e inténtalo de nuevo.').removeClass('d-none').slideDown(600);

            }).fail(function(){
                $('#modal-descarga-lista').modal('toggle');
                $('#notice-avanzada').empty().html('Lo sentimos no se pudo procesar tu petición, asegurate de haber anotado correctamente tu correo e inténtalo de nuevo.').removeClass('d-none').slideDown(600);
            });

        } else
            return false;
    });

    // Para la validacion del correo en la descarga de la lista
    dameValidacionCorreo('lista', '#notice-avanzada');
});