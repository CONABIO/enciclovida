// Inicializa las funciones del show de especies
var showEspecies  =function()
{
    tooltip();
    refreshMediaQueries();
    nombres_comunes_todos();
    iniciaPestañas();

    // Para correr las imagenes principales
    if (INATURALIST_API != undefined) fotos_naturalista(); else fotos_bdi();
};

// Pone el evento en las pestañas
var iniciaPestañas = function()
{
    $('#pestañas > .nav a').one('click',function(){
        if (!Boolean($(this).hasClass('noLoad'))){
            var idPestaña = $(this).data('params') || this.getAttribute('href').replace('#','');
            var pestaña = '/especies/'+TAXON.id+'/'+idPestaña;
            $(this.getAttribute('href')).load(pestaña);
        }
    });
};

// Para correr los nobres comunes del lado del cliente
var nombres_comunes_todos = function(id)
{
    $('#nombres_comunes_todos').load("/especies/" + TAXON.id + "/nombres-comunes-todos");
};

$(document).ready(function(){
    cual_ficha = '';

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

    var despliegaOcontrae = function(id)
    {
        var sufijo = id.substring(5);

        if ($("#nodo_" + sufijo + " li").length > 0)
        {
            var minus = $('#span_' + sufijo).hasClass("glyphicon-minus");

            if (minus)
                $('#span_' + sufijo).removeClass("glyphicon-minus").addClass("glyphicon-plus");

            $("#nodo_" + sufijo + " li").remove();

        } else {
            var origin_id = window.location.pathname.split('/')[2];

            $.ajax(
                {
                    url: "/especies/" + sufijo + "/hojas_arbol_identado?origin_id=" + origin_id
                }).done(function(nodo)
                {
                    var plus = $('#span_' + sufijo).hasClass("glyphicon-plus");

                    if (plus)
                        $('#span_' + sufijo).removeClass("glyphicon-plus").addClass("glyphicon-minus");

                    return $("#nodo_" + sufijo).append(nodo);
                });
        }
        return false;
    };

    $('#content').on('click', '#boton_pdf', function(){
        window.open("/especies/"+TAXON.id+".pdf?from="+cual_ficha);
    });

    $('#taxon_description').on('change', '#from', function(){
        cual_ficha = $(this).val();

        $.ajax({
            url: "/especies/"+TAXON.id+"/describe?from="+cual_ficha,
            method: 'get',
            success: function(data, status) {
                $('.taxon_description').replaceWith(data);
            },
            error: function(request, status, error) {
                $('.taxon_description').loadingShades('close');
            }
        });
    });

    $(document).on('click', '.historial_ficha', function(){
        var comentario_id = $(this).attr('comentario_id');
        var especie_id = $(this).attr('especie_id');
        $("#historial_ficha_" + comentario_id).load("/especies/"+especie_id+"/comentarios/"+comentario_id+"/respuesta_externa?ficha=1");
        $("#historial_ficha_" + comentario_id).slideDown();
        return false;
    });
});
