/**
 * Quita parametros de la URL actual
 * @param sParam
 * @returns {string}
 */
var quitaParametros = function(sParam)
{
    var url = window.location.href.split('?')[0]+'?';
    var sPageURL = decodeURIComponent(window.location.search.substring(1)),
        sURLVariables = sPageURL.split('&'),
        sParameterName,
        i;

    for (i = 0; i < sURLVariables.length; i++) {
        sParameterName = sURLVariables[i].split('=');
        if (sParameterName[0] != sParam) {
            url = url + sParameterName[0] + '=' + sParameterName[1] + '&'
        }
    }
    return url.substring(0,url.length-1);
};

/**
 * Para el pagiando con de metamares
 * @param paginas
 * @param pagina
 */
var paginadoMetamares = function(paginas, pagina)
{
    console.log(pagina);
    console.log(paginas);
    href = quitaParametros('pagina');
    var url = href.split('/').pop();

    if (url == 'proyectos')
        var param = '?';
    else
        var param = '&';

    $('.paginado-metamares').bootpag({
        total: paginas,          // total pages
        page: pagina,            // default page
        maxVisible: 5,     // visible pagination
        leaps: true,         // next/prev leaps through maxVisible
        firstLastUse: true,
        first: '←',
        last: '→'
    }).on("page", function(event, /* page number here */ num){
        window.location.replace(href + param + "pagina=" + num);
    });
};


$(document).ready(function() {
    soulmateAsigna('metamares', 'proy_b_nombre');
});