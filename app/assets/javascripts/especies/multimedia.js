$(document).ready(function(){

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