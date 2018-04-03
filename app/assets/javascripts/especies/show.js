//= require ../photo_selectors.js

var nombres_comunes_todos = function(id)
{
    $('#nombres_comunes_todos').load("/especies/" + id + "/nombres-comunes-todos");
};

var imagenes_taxon = function(p)
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
};

var paginado_fotos = function(paginas, pagina)
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
                    url: '/especies/' + TAXON.id + '/fotos-bdi.html',
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
    $('#modal_reproduce').on('show.bs.modal', function (event) {
        var button = $(event.relatedTarget); // Button that triggered the modal
        var media;
        $('#modal_reproduce_body .col-md-3 > h3').text(button.data('author'));
        $('#modal_reproduce_body .col-md-3 > h4').text(button.data('date'));
        $('#modal_reproduce_body .col-md-3 > h5').text(button.data('country'));
        $('#modal_reproduce_body .col-md-3 > p').text(button.data('location'));
        $('#modal_reproduce_label > a').attr('href', button.data('title'));
        if(button.data('type') == 'photo'){
            media = $(document.createElement("img")).addClass('img-responsive').attr('src', button.data('url'));
        }else{
            var video = $(document.createElement("video")).attr('controls','').attr('controlsList', 'nodownload').attr('autoplay','');
            var source = $(document.createElement("source")).attr('src', button.data('url'));
            media = video.append(source);
        }
        $('#modal_reproduce_label > a').attr('href', button.data('title'));
        $('#modal_reproduce_body .col-md-9').append(media);
    });
    //Deshabilitar clicks derechos en ALL el modal
    $('#modal_reproduce_body').bind('contextmenu', function(e) {
        e.stopPropagation();
        e.preventDefault();
        e.stopImmediatePropagation();
        return false;
    });
    //Eliminar contenido del modal-body (necesario para q deje de reproducirse el video/audio cuando se cierra modal)
    $('#modal_reproduce').on('hide.bs.modal', function(){$('#modal_reproduce_body .col-md-9').empty()});
});
