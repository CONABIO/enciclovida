/**
 * Para el pagiando con las fotos de BDI
 * @param paginas
 * @param pagina
 */
var paginadoFotosBDI = function(paginas, pagina)
{
    var es_primero = null;

    $('.paginado_1, .paginado_2').bootpag({
        total: paginas,          // total pages
        page: pagina,            // default page
        maxVisible: 5,     // visible pagination
        leaps: true,         // next/prev leaps through maxVisible
        firstLastUse: true,
        first: '←',
        last: '→'
    }).on("page", function (event, pag) {
        if (es_primero == pag)
            return;
        else {
            $.ajax(
                {
                    url: '/especies/' + opciones.taxon + '/fotos-bdi.html',
                    type: 'GET',
                    data: {
                        pagina: pag
                    }
                }).done(function (res) {
                $('#paginado_fotos').empty().append(res);
            });
        }

        es_primero = pag;
    });
};
