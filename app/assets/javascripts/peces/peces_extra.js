var limpiaBusqueda = function(){
    var controles = ".porGrupo input, .porSemaforo input, .porZonas input, .porNombreGrupo input, .porNombreGrupo select, .porCriterios input, .porCriterios select";
    var visuales = ".porGrupo span, .porSemaforo span, .porZonas span, .porZonas path, .porCriterios span";
    var inputsALimpiar = $(controles + ", " + visuales);
    inputsALimpiar.attr("disabled", false).removeClass("disabled zona-seleccionada");
    $("#id, #nombre").val('');
    inputsALimpiar.prop("checked", false);
};

var bloqueaBusqueda = function(){
    var controles = ".porGrupo input, .porSemaforo input, .porZonas input, .porNombreGrupo select, .porCriterios input, .porCriterios select";
    var visuales = ".porGrupo span, .porSemaforo span, .porZonas span, .porZonas path, .porCriterios span";
    var inputsABloquear = $(controles + ", " + visuales);
    inputsABloquear.attr("disabled", true).addClass("disabled");
    //inputsABloquear.val('');
    inputsABloquear.prop("checked", false);

};

$(document).ready(function(){
    TYPES = ['peces'];
    soulmateAsigna('peces');

    $('[data-toggle="popover"]').one('click', function(){
        var button = $(this);
        var idEspecie = $(button).data('especie-id');
        var pestaña = '/pmc/peces/'+idEspecie+'?mini=true';
        jQuery.get(pestaña).done(function(data){
            button.popover({
                html:true,
                container: 'body',
                placement: function(){
                    if($(window).width() < 990){
                        return 'bottom'
                    }else{
                        if(($(window).width() - button.offset().left) < $(window).width()/2){
                            return 'left';
                        }else{
                            return 'right';
                        }
                    }
                },
                trigger: 'click',
                content: data
            }).popover('show');
        });
    });

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
});

var scroll_array = false;

var scrollToAnchor = function(){
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
};