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
    soulmate_asigna('peces');

    $(".btn-ficha").one('click',function(){
        idEspecie = $(this).data('especie-id');
        pestaña = '/peces/'+idEspecie+'?layout=0';
        $('#datos-'+idEspecie).load(pestaña);
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
