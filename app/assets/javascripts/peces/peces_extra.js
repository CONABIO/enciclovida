var limpiaBusqueda = function()
{
    $(".agrupada *, .recomendada *, #nombre").attr("disabled", false).removeClass("disabled");
    $( "#especie_id, #nombre" ).val('');
};

var bloqueaBusqueda = function()
{
};

$(document).ready(function(){
    TYPES = ['peces'];
    soulmateAsigna('peces');
    
    $('#multiModal').on('show.bs.modal', function (event) {
        button = $(event.relatedTarget); // Button that triggered the modal
        idEspecie = $(button).data('especie-id');
        pestaña = '/peces/'+idEspecie+'?layout=0 #panel-body';
        $('#multiModalBody').load(pestaña);
        $('#multiModalLabel').html(button.siblings('.result-nombre-container').children('h4').html());
        $('#multiModalLabel_bis').html(button.siblings('.result-nombre-container').children('h5').html());
    });

    //Eliminar contenido del modal-body (necesario para q deje de reproducirse el video/audio cuando se cierra modal)
    $('#multiModal').on('hide.bs.modal', function(){$('#multiModalBody').empty()});


    $("path[id^=path_zonas_]").on('click', function(){
        $(this).toggleClass('zona-seleccionada');
        var input = $('#' + this.id.replace('path_',''));
        input.prop("checked", !input.prop("checked"));
    });

    $(window).load(function(){
        $("html,body").animate({scrollTop: 122}, 1000);
    });
});
