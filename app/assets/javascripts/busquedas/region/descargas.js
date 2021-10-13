$(document).ready(function(){
    // Incluir en donde se genera el contenido dinamico
    $('#modal-descarga-region').on('click', '.boton-descarga', function (event) {
        var correo = $('#modal-descarga-region input[name=correo]').val();
        var form_serialize = $('#modal-descarga-region form').serialize();

        if(correoValido(correo))
        {
            $.ajax({
                url: '/explora-por-region/especies.xlsx',
                type: 'GET',
                dataType: "json",
                data: serializeParametros() + '&' + form_serialize
            }).done(function(resp) {
                $('#modal-descarga-region').modal('toggle');

                if (resp.estatus)
                    $('#notice').empty().html('!La petición se envió correctamente!. Se te enviará un correo con los resultados de tu búsqueda!').removeClass('d-none').slideDown(600);
                else
                    $('#notice').empty().html('Lo sentimos no se pudo procesar tu petición, verifica tus filtros y correo.').removeClass('d-none').slideDown(600);

            }).fail(function(){
                $('#modal-descarga-region').modal('toggle');
                $('#notice').empty().html('Lo sentimos no se pudo procesar tu petición, verifica tus filtros y correo.').removeClass('d-none').slideDown(600);
            });

        } else {
            $('#modal-descarga-region').modal('toggle');
            $('#notice').empty().html('Lo sentimos no se pudo procesar tu petición, asegurate de haber anotado correctamente tu correo e inténtalo de nuevo.').removeClass('d-none').slideDown(600);
            event.preventDefault();
        }
    });

    // Para al descarga en PDF de la guia
    $('#modal-descarga-guia').on('click', '.boton-descarga', function (event) {
        var correo = $('#modal-descarga-guia input[name=correo]').val();
        var form_serialize = $('#modal-descarga-guia input').serialize();
        var url_guia = window.location.href.replace("/explora-por-region", "/explora-por-region/especies.pdf")

        if(correoValido(correo))
        {
            $.ajax({
                url: url_guia,
                type: 'GET',
                dataType: "json",
                data: form_serialize
            }).done(function(resp) {
                $('#modal-descarga-guia').modal('toggle');

                if (resp.estatus)
                    $('#notice').empty().html('!La petición se envió correctamente!. Se te enviará un correo con los resultados de tu búsqueda!').removeClass('d-none').slideDown(600);
                else
                    $('#notice').empty().html('Lo sentimos no se pudo procesar tu petición, verifica tus filtros y correo.').removeClass('d-none').slideDown(600);

            }).fail(function(){
                $('#modal-descarga-guia').modal('toggle');
                $('#notice').empty().html('Lo sentimos no se pudo procesar tu petición, verifica tus filtros y correo.').removeClass('d-none').slideDown(600);
            });

        } else {
            $('#modal-descarga-guia').modal('toggle');
            $('#notice').empty().html('Lo sentimos no se pudo procesar tu petición, asegurate de haber anotado correctamente tu correo e inténtalo de nuevo.').removeClass('d-none').slideDown(600);
            event.preventDefault();
        }
    });
    
    // Para la validacion del correo en la descarga de la lista y guia
    dameValidacionCorreo('region', '#notice');
    dameValidacionCorreo('guia', '#notice');
});