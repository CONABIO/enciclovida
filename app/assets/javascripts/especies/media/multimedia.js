$(document).ready(function(){

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

        $('#modal_copyright').text(", " + button.data('copyright'));

        $('#modal_title').text(button.data('title'));

        $('#modal_specimen').text(button.data('specimen'));
        $('#modal_img_descripcion').text(button.data('descripcion'));
        $('#modal_img_tipo').text(button.data('imgKind'));

        // En el caso de que el tipo sea image:
        if(button.data('type') == 'photo'){

            /* OPCIÓN 1: Inicial * /
            media = $(document.createElement("img")).addClass('img-responsive').attr('src', button.data('url'));
            /* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */

            /* OPCIÓN 2: Imagen como fondo de un div del tamaño del contenedor */
            media = $(document.createElement("div"));
            media.css({
                'width' : '100%',
                'height' : '100%',
                'background' : 'url(' + button.data('url') +')',
                'background-size': 'contain',
                'background-position': 'center center',
                'background-repeat':'no-repeat'
            });
            // Opción 2.1 $("#img-container").css("height", $(window).height() * 0.75);
            // Opcoón 2.2
            resizeImgContainer(button.data('url'));
            /* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */

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
});


function resizeImgContainer(url_img) {
    var height = 0;
    var width = 0;
    var img = new Image();
    img.src = url_img;
    var windowSpace = $(window).height() * 0.75;

    img.onload = function() {
        height = img.height;
        width = img.width;

        $("#img-container").removeClass("embed-responsive-16by9");

        // Verificar el tamaño en alto de la imagen:
        if(height >= windowSpace) {
            // Si es más grande que el alto del navegador, usar el alto de el tamaño el navegador para el contenedor
            $("#img-container").css("height", windowSpace);

            // Si la imágen es alta
            if(height > width) {
                // Usar el ancho "autómatico"
                $("#modalTamanio").css("width",  "");
            } else {
                // Si es ancha, ocupar el 80% de la pantalla para mostrarla
                $("#modalTamanio").css("width",  "80%");
            }

        } else {
            // Si es menor al tamaño del navegador, usar el alto de la imagen para el contenedor
            $("#img-container").css("height", height);
            $("#modalTamanio").css("width",  "");
        }
    };
}