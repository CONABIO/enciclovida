//= require photo_selectors

function nombres_comunes_todos()
{
    $('#nombres_comunes_todos').load("/especies/" + TAXON.id + "/nombres-comunes-todos");
}

function imagenes_taxon(p)
{
    $.ajax(
        {
            url: BDI_API,
            type: 'GET',
            data: {p: p}
        }).done(function (fotos) {

        }).error(function (error) {
            $('#imagenes_taxon').html('Lo sentimos, no contamos con una imágen para esta especie, <a href="http://www.biodiversidad.gob.mx/recursos/bancoimg.html">¿quieres contribuir proporcionando una imágen?</a>');
        });
}

$(document).ready(function(){
    cual_ficha = '';

    info = function(){
        $('#ficha-div').slideUp();
        $('#info-div').slideDown();
        return false;
    };

    ficha = function(){
        $('#info-div').slideUp();
        $('#ficha-div').slideDown();
        return false;
    };

    muestraBibliografiaNombres = function(ident){
        var id=ident.split('_')[2];
        $("#biblio_"+id).dialog();
        return false;
    };

    despliegaOcontrae = function(id)
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

    $(document).on('click', '#boton_pdf', function(){
        window.open("/especies/"+TAXON.id+".pdf?from="+cual_ficha);
    });

    $(document).on('change', '#from', function(){
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

    $('#pestañas > .nav a').one('click',function(){
        if (!Boolean($(this).hasClass('noLoad'))){
            idPestaña = $(this).data('params') || this.getAttribute('href').replace('#','');
            pestaña = '/especies/'+TAXON.id+'/'+idPestaña;
            $(this.getAttribute('href')).load(pestaña);
        }
    });

    $("[id^='mediaCornell_']").on('click','nav a',function(){
        divDestino = $(this).parents("[id^='mediaCornell_']");//jQueryObj

        urlParams = $(this).data('params');
        numPage = divDestino.data('page') + $(this).data('direccion');

        if(numPage < 1){
            $('.previous a').addClass('disabled');
            return false;
        }
        if(divDestino.find('.result-img-container').length < 20){
            $('.next a').addClass('disabled');
            return false;
        }

        urlRequest= '/especies/'+TAXON.id+'/'+urlParams+'&page='+numPage;
        divDestino.children('.inner_media').load(urlRequest, function(){
            divDestino.find('nav a').removeClass('disabled');
        });
        divDestino.data('page', numPage);
        return false;
    });

    $('#modal_reproduce').on('show.bs.modal', function (event) {
        var button = $(event.relatedTarget); // Button that triggered the modal
        var media;

        var ubicacion = [];
        [button.data('state'),button.data('country')].forEach(function(cValue){
            if(cValue != ''){ubicacion.push(cValue)}
        });

        $('#modal_localidad').text(button.data('locality'));
        $('#modal_ubicacion').text(ubicacion.join(', '));
        $('#modal_fecha').text(button.data('date'));
        $('#modal_observacion').attr('href', button.data('observation'));
        $('#modal_autor').text(button.data('author'));
        if(button.data('type') == 'photo'){
            media = $(document.createElement("img")).addClass('img-responsive').attr('src', button.data('url'));
        }else{
            var video = $(document.createElement("video")).attr('controls','').attr('controlsList', 'nodownload').attr('autoplay','');
            var source = $(document.createElement("source")).attr('src', button.data('url'));
            media = video.append(source);
        }
        $('#modal_reproduce_body .embed-responsive').append(media);
    });
    //Deshabilitar clicks derechos en ALL el modal
    $('#modal_reproduce_body').bind('contextmenu', function(e) {
        e.stopPropagation();
        e.preventDefault();
        e.stopImmediatePropagation();
        return false;
    });
    //Eliminar contenido del modal-body (necesario para q deje de reproducirse el video/audio cuando se cierra modal)
    $('#modal_reproduce').on('hide.bs.modal', function(){$('#modal_reproduce_body .embed-responsive').empty()});
});
