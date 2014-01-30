/**
 * Created with JetBrains RubyMine.
 * User: calonso
 * Date: 1/27/14
 * Time: 4:11 PM
 * To change this template use File | Settings | File Templates.
 */

$(document).ready(function(){
    $('#busqueda_avanzada_link').click(function(){
        $('#busqueda_avanzada').slideToggle();
    });

    $('#busqueda_basica_link').click(function(){
        $('#busqueda_avanzada').slideToggle();
    });
});


