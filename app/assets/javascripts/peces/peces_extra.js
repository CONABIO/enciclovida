var limpiaBusqueda = function(){
    $(".agrupada *, .recomendada *, #nombre").attr("disabled", false).removeClass("disabled");
    $( "#especie_id, #nombre" ).val('');
};

var bloqueaBusqueda = function(){
};

$(document).ready(function(){
    TYPES = ['peces'];
    soulmateAsigna('peces');

    $('#multiModal').on('show.bs.modal', function (event) {
        var button = $(event.relatedTarget); // Button that triggered the modal IMPORTANTE
        var idEspecie = $(button).data('especie-id');
        var pestaña = '/peces/'+idEspecie+'?layout=0 #panel-body';
        $('#multiModalBody').load(pestaña);
        $('.modal-header').append(button.siblings('.result-nombre-container').children('h5').clone());
    });

    //Eliminar contenido del modal-body y modal header (para poder reutilizar el modal en peces)
    $('#multiModal').on('hide.bs.modal', function(){
        $('#multiModalBody').empty();
        $('.modal-header h5').remove();
    });

    $("path[id^=path_zonas_]").on('click', function(){
        $(this).toggleClass('zona-seleccionada');
        var input = $('#' + this.id.replace('path_',''));
        input.prop("checked", !input.prop("checked"));
    });

    $(window).load(function(){
        $("html,body").animate({scrollTop: 122}, 1000);
    });
});

var scroll_array = 1;

var scrollToAnchor = function(){
    if(scroll_array == 0){
        $("html,body").animate({scrollTop: $('#busqueda_avanzada').offset().top},'slow');
        scroll_array =  1;
    }else{
        $('html,body').animate({scrollTop: $('#scroll_down_up').offset().top},'slow');
        scroll_array = 0;
    }
    $('#scroll_down_up span').toggleClass("glyphicon-menu-down glyphicon-menu-up");
};