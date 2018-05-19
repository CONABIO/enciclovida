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
            $( "#ncientifico_id" ).val( ui.item.especie_id );
            $( "#ncientifico" ).val( ui.item.value );
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
            $( "#ncomunes_id" ).val( ui.item.especie_id );
            $( "#ncomunes" ).val( ui.item.value );
            return false;
        }
    });
});