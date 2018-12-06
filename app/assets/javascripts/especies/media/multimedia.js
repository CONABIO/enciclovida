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

    // Para trópicos:
    $('#modal_reproduce_trop').on('show.bs.modal', function (event) {
        var button = $(event.relatedTarget); // Button that triggered the modal
        var media;
        console.log("Entro en la parte de tropicos")
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
    $('#modal_reproduce_trop_body').bind('contextmenu', function(e) {
        e.stopPropagation();
        e.preventDefault();
        e.stopImmediatePropagation();
        return false;
    });

});