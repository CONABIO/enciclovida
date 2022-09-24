var limpiaBusqueda = function(){
    var controles = ".porGrupo input, .porSemaforo input, .porSustentable input, .porZonas input, .porNombreGrupo input, .porNombreGrupo select, .porCriterios input, .porCriterios select";
    var visuales = ".porGrupo span, .porSemaforo span, .porSustentable span, .porZonas span, .porZonas path, .porCriterios span";
    var inputsALimpiar = $(controles + ", " + visuales);
    inputsALimpiar.attr("disabled", false).removeClass("disabled zona-seleccionada").prop("checked", false);
    $("#id, #nombre, .porNombreGrupo input, .porNombreGrupo select").val('');
    $('#edo_cons').selectpicker('val','');
};

var bloqueaBusqueda = function(){
    var controles = ".porGrupo input, .porSemaforo input, .porSustentable input, .porZonas input, .porNombreGrupo select, .porCriterios input, .porCriterios select";
    var visuales = ".porGrupo span, .porSemaforo span, .porSustentable span, .porZonas span, .porZonas path, .porCriterios span";
    var inputsABloquear = $(controles + ", " + visuales);
    inputsABloquear.attr("disabled", true).addClass("disabled").prop("checked", false);
};

var asignaFiltros = function(params)
{
    if (params.edo_cons != undefined) $('#edo_cons').selectpicker('val',params.edo_cons);
};

$(document).ready(function(){
    TYPES = ['peces'];
    soulmateAsigna('peces');



    $("path[id^=path_zonas_]").on('click', function(){
        $(this).toggleClass('zona-seleccionada');
        var input = $('#' + this.id.replace('path_',''));
        input.prop("checked", !input.prop("checked"));
    });


    $(".porZonas input").each(function(index, item){
        if($(item).prop('checked')){
            $('#path_' + item.id).addClass('zona-seleccionada');
        }
    });

    $("html,body").animate({scrollTop: 105}, 500);

    if($('#id').val()!=''){bloqueaBusqueda();}

});

var scroll_array = false;

/*var scrollToAnchor = function(){
    if(scroll_array){
        $('#porCriterios').css('display', 'none');
        $("html,body").animate({scrollTop: $('#busqueda_avanzada').offset().top},'slow');
        scroll_array =  false;
    }else{
        $('#porCriterios').css('display', 'block');
        $('html,body').animate({scrollTop: $('#scroll_down_up').offset().top},'slow');
        scroll_array = true;
    }
    $('#scroll_down_up span').toggleClass("glyphicon-menu-down glyphicon-menu-up");
};*/