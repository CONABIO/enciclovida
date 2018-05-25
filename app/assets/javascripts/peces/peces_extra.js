$( function() {
    var cache = {};
    $( "#ncientifico" ).autocomplete({
        minLength: 2,
        source: function( request, response ) {
            var term = request.term;
            if ( term in cache ) {
                response( cache[ term ] );
                return;
            }
            $.getJSON( "dameNombre?tipo=cientifico", request, function( data, status, xhr ) {
                cache[ term ] = data;
                console.log(data);
                response( data );
            });
        },
        select: function( event, ui ) {
            $( "#especie_id" ).val( ui.item.especie_id );
            $( "#ncientifico" ).val( ui.item.value );
            $( "#ncomunes" ).val('');
            $( ".valorada select, .valorada input, .valorada span, .agrupada select, .recomendada select, .recomendada input, .recomendada span, #ncomunes" ).attr('disabled', true).addClass('disabled');
            $( "#rango" ).slider( "disable" );
            return false;
        }
    });
});

$( function() {
    var cache = {};
    $( "#ncomunes" ).autocomplete({
        minLength: 2,
        source: function( request, response ) {
            var term = request.term;
            if ( term in cache ) {
                response( cache[ term ] );
                return;
            }
            $.getJSON( "dameNombre?tipo=comunes", request, function( data, status, xhr ) {
                cache[ term ] = data;
                console.log(data);
                response( data );
            });
        },
        select: function( event, ui ) {
            $( "#especie_id" ).val( ui.item.especie_id );
            $( "#ncomunes" ).val( ui.item.value );
            $( "#ncientifico" ).val('');
            $( ".valorada select, .valorada input, .valorada span, .agrupada select, .recomendada select, .recomendada input, .recomendada span, #ncientifico" ).attr('disabled', true).addClass('disabled');
            $( "#rango" ).slider( "disable" );
            return false;
        }
    });
});
$(document).ready(function(){
    $(".btn-ficha").one('click',function(){
        idEspecie = $(this).data('especie-id');
        pestaña = '/peces/'+idEspecie+'?layout=0';
        $('#datos-'+idEspecie).load(pestaña);
    });
});

function limpiaBusqueda(){
    $(".valorada *, .agrupada *, .recomendada *, #ncientifico, #ncomunes").attr("disabled", false).removeClass("disabled");
    $( "#rango" ).slider( "enable" );
    $( "#especie_id, #ncientifico, #ncomunes, #valor_total" ).val('');
};
