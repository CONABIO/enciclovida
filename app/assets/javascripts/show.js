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

    //$('#pestañas').tabs(); // Inicia los tabs
    /*$('#pestañas > .nav a').click(function(){
        $('#pestañas > .nav li').removeClass("active");
        console.log(this);
        $(this).parent().addClass("active");
    }).one('click',function(){
        console.log(this);
        if (!Boolean($(this).hasClass('noLoad'))){
            console.log('WTF!!');
            idPestaña = this.getAttribute('href').replace('#','');
            pestaña = '/especies/'+TAXON.id+'/'+idPestaña;
            $(document.getElementById(idPestaña)).load(pestaña);
            console.log('WTF!!x2');
        }
    });*/
    $('#pestañas > .nav a').click(function(){
        //$('#pestañas > .nav li').removeClass("active");
        //console.log(this);
        //$(this).parent().addClass("active");
    }).one('click',function(){

        if (!Boolean($(this).hasClass('noLoad'))){
            idPestaña = this.getAttribute('href').replace('#','');
            pestaña = '/especies/'+TAXON.id+'/'+idPestaña.replace('_','?type=');
            $(document.getElementById(idPestaña)).load(pestaña);
        }

    });
    $('#modal_reproduce').on('show.bs.modal', function (event) {
        var button = $(event.relatedTarget); // Button that triggered the modal
        var media;
        if(button.data('type') == 'p'){
            media = $(document.createElement("img")).addClass('img-responsive').attr('src', button.data('url'));
        }else{
            var video = $(document.createElement("video")).attr('controls','').attr('controlsList', 'nodownload').attr('autoplay','');
            var source = $(document.createElement("source")).attr('src', button.data('url'));
            media = video.append(source);
        }
        $('#modal_reproduce_label > a').attr('href', button.data('title'));
        $('#modal_reproduce_body .col-md-9').append(media);
    });

    $('#modal_reproduce').on('hide.bs.modal', function(){$('#modal_reproduce_body .col-md-9').empty()});// eliminar contenido del body en la reproduccion de los videos

});
