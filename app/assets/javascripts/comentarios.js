function es_correo(email) {
    var regex = /^([a-zA-Z0-9_.+-])+\@(([a-zA-Z0-9-])+\.)+([a-zA-Z0-9]{2,4})+$/;
    return regex.test(email);
}

$(document).ready(function(){
    $('#comentario_submit').click(function(){
        if ($('#comentario_correo').val() != undefined && $('#comentario_correo').val() == '')
        {
            $('#error_mensaje').empty().html('El correo no puede ser vacio.');
            return false;
        } else if ($('#comentario_correo').val() != undefined) {
            if (!es_correo($('#comentario_correo').val()))
            {
                $('#error_mensaje').empty().html('El correo no es válido, por favor verifica.');
                return false;
            }
        }
        if ($('#comentario_nombre').val() != undefined && $('#comentario_nombre').val() == '')
        {
            $('#error_mensaje').empty().html('El nombre no puede ser vacio.');
            return false;
        }
        if ($('#comentario_comentario').val() == '')
        {
            $('#error_mensaje').empty().html('El comentario no puede ser vacio.');
            return false;
        }
    });
});
