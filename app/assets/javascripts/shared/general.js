//Variable para ofuscar correo
var co = ["xm.bo","g.oiba","noc","@adivol","cicne:o","tliam"];

/**
 * Emula el comportamiento de la funcion limpiar en ruby
 */
var limpiar = function (str)
{
    return str.replace(/\([^()]*\)/i, "").trim();
};

/**
 * Pone el tamaño inicial al mapa
 */
var ponTamaño = function () {
    $('#map').css('height', 0);
    $('#contenedor_mapa').addClass('embed-responsive embed-responsive-23by9');
    $('#map').css('height', $('#contenedor_mapa').height());
    map.invalidateSize(true);
    $('#contenedor_mapa').removeClass('embed-responsive embed-responsive-23by9');
};

/**
 * Para validar el correo
 * @param correo
 * @returns {boolean}
 */
var correoValido = function (correo)
{
    var pattern = /^([a-z\d!#$%&'*+\-\/=?^_`{|}~\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF]+(\.[a-z\d!#$%&'*+\-\/=?^_`{|}~\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF]+)*|"((([ \t]*\r\n)?[ \t]+)?([\x01-\x08\x0b\x0c\x0e-\x1f\x7f\x21\x23-\x5b\x5d-\x7e\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF]|\\[\x01-\x09\x0b\x0c\x0d-\x7f\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF]))*(([ \t]*\r\n)?[ \t]+)?")@(([a-z\d\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF]|[a-z\d\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF][a-z\d\-._~\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF]*[a-z\d\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])\.)+([a-z\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF]|[a-z\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF][a-z\d\-._~\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF]*[a-z\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])\.?$/i;
    return pattern.test(correo);
};

/**
 * La primera letra a mayuscula
 * @param str
 * @returns {string}
 */
function primeraEnMayuscula( str ) {
    return str.substr(0, 1).toUpperCase() + str.substr(1);
}

/**
 * Cambia entre vista general y de especialistas
 * @param locale
 * @returns {boolean}
 */
var cambiaLocale = function(locale){
    $.ajax(
        {
            url: "/usuarios/cambia_locale",
            type: 'POST',
            data: {
                locale: locale
            }
        }).done(function(resp){
        if (resp.estatus) location.reload(true);
        return false;
    });
    return false;
};

/**
 * Pequeño hack para mejorar el title de los iconos, agregar solo clase .btn-title
 */
var tooltip = function(clase){
        $(clase).tooltip({
            html:true,
            sanitize:false,
            container: 'body',
            placement: 'bottom',
            boundary: 'window',
            trigger: 'hover'
    });
};


/**
 * Para general el scrolling en la pagina
 * @param objeto
 * @param por_pagina
 * @param url
 */
var scrolling_page = function(objeto, por_pagina, url)
{
    $(objeto).scrollPagination({
        nop     : por_pagina, // The number of posts per scroll to be loaded
        offset  : 2, // Initial offset, begins at 0 in this case
        error   : '', // When the user reaches the end this is the message that is
        // displayed. You can change this if you want.
        delay   : 500, // When you scroll down the posts will load after a delayed amount of time.
                       // This is mainly for usability concerns. You can alter this as you see fit
        scroll  : true, // The main bit, if set to false posts will not load as the user scrolls.
        // but will still load if the user clicks.
        url     : url
    });
};

/**
 * Para validar el correo del lado del cliente 
 * @param {*} recurso 
 * @param {*} notice 
 */
var dameValidacionCorreo = function(recurso, notice)
{  
    $('#modal-descarga-' + recurso).on('keyup', 'input[name=correo]', function(){
        $(notice).empty().addClass('hidden');

        if( !correoValido($(this).val()) )
            $('#modal-descarga-' + recurso + ' .boton-descarga').attr('disabled', 'disabled');
        else
            $('#modal-descarga-' + recurso + ' .boton-descarga').removeAttr('disabled');
    });
};

$(document).ready(function(){
    tooltip(".btn-title");
});

