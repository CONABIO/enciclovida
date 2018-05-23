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
            $( ".agrupada select, #ncomunes" ).attr('disabled', true).addClass('disabled');
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
            $( ".agrupada select, #ncientifico" ).attr('disabled', true).addClass('disabled');
            return false;
        }
    });
});
$( function() {
    $( "#rango" ).slider({
        range: true,
        min: -5,
        max: 70,
        values: [-5,4],
        slide: function( event, ui ) {
            $( "#valor_total" ).val(ui.values[ 0 ] + "," + ui.values[ 1 ] );
            $("#resultados").load('/peces/busqueda?semaforo_vt=' + $( "#rango" ).slider( "values", 0 ) + ',' + $( "#rango" ).slider( "values", 1 ));
        }
    });
    //$( "#valor_total" ).val($( "#rango" ).slider( "values", 0 ) + ',' + $( "#rango" ).slider( "values", 1 ) );
  } );

function limpiaBusqueda(){
    $(".agrupada select, #ncientifico, #ncomunes").attr("disabled", false).removeClass("disabled");
    $( "#especie_id, #ncientifico, #ncomunes" ).val('');
};
