/**
 * // Inicializa las funciones del show de especies
 */
var showEspecies  =function()
{
    tooltip();
    refreshMediaQueries();
    nombresComunes();
    eventoPestañas();

    // Para correr las imagenes principales
    if (INATURALIST_API != undefined) fotos_naturalista(); else fotos_bdi();
};

// Pone el evento en las pestañas
var eventoPestañas = function()
{
    $('#pestañas > .nav a').one('click',function(){
        if (!Boolean($(this).hasClass('noLoad'))){
            var idPestaña = $(this).data('params') || this.getAttribute('href').replace('#','');
            var pestaña = '/especies/'+TAXON.id+'/'+idPestaña;
            $(this.getAttribute('href')).load(pestaña);
        }
    });
};

// Para correr los nobres comunes del lado del cliente, pone de catalogos y naturalista
var nombresComunes = function()
{
    $('#nombres_comunes_todos').load("/especies/" + TAXON.id + "/nombres-comunes-todos");
};

$(document).ready(function(){

    $('#enlaces_externos').on('click', '#boton_pdf', function(){
        window.open("/especies/"+TAXON.id+".pdf?from="+cual_ficha);
    });

    var info = function(){
        $('#ficha-div').slideUp();
        $('#info-div').slideDown();
        return false;
    };

    var ficha = function(){
        $('#info-div').slideUp();
        $('#ficha-div').slideDown();
        return false;
    };

    var muestraBibliografiaNombres = function(ident){
        var id=ident.split('_')[2];
        $("#biblio_"+id).dialog();
        return false;
    };

    $(document).on('click', '.historial_ficha', function(){
        var comentario_id = $(this).attr('comentario_id');
        var especie_id = $(this).attr('especie_id');
        $("#historial_ficha_" + comentario_id).load("/especies/"+especie_id+"/comentarios/"+comentario_id+"/respuesta_externa?ficha=1");
        $("#historial_ficha_" + comentario_id).slideDown();
        return false;
    });
});
