$(document).ready(function(){
    tooltip();
    refreshMediaQueries();

    $('#navegacion a.load-tab').one('click',function(){
        var idPestaña = $(this).data('params') || this.getAttribute('href').replace('#','');
        var pestaña = '/especies/' + opciones.taxon + '/'+idPestaña;
        $(this.getAttribute('href')).load(pestaña, function () {
            switch (idPestaña) {
                case 'media':
                    $('#mediaBDI_p').load('/especies/' + opciones.taxon + '/bdi-photos?type=photo', function () {
                        //$('#mediaBDI_v').load('/especies/' + opciones.taxon + '/bdi-videos?type=video', function () {
                            $('#mediaCornell_p').load('/especies/' + opciones.taxon + '/media-cornell?type=photo', function () {
                                $('#mediaCornell_v').load('/especies/' + opciones.taxon + '/media-cornell?type=video', function () {
                                    $('#mediaCornell_a').load('/especies/' + opciones.taxon + '/media-cornell?type=audio',function () {
                                        $('#mediaTropicos').load('/especies/' + opciones.taxon + '/media-tropicos');
                                    });
                                });
                            });
                        //});
                    });
                    break;
                case 'descripcion_catalogos':
                    $('.biblio-cat').popover({html: true});
                    break;
                default:
                    break;
            }
        });
    });
    if (opciones.naturalista_api != undefined) fotosNaturalista(); else fotosBDI();

    $('#nombres_comunes_todos').load("/especies/" + opciones.taxon + "/nombres-comunes-todos");

    $('#enlaces_externos').on('click', '#boton_pdf', function(){
        window.open("/especies/" + opciones.taxon + ".pdf?from=" + opciones.cual_ficha);
    });

    $(document).on('click', '.historial_ficha', function(){
        var comentario_id = $(this).attr('comentario_id');
        var especie_id = $(this).attr('especie_id');
        $("#historial_ficha_" + comentario_id).load("/especies/" + especie_id + "/comentarios/" + comentario_id + "/respuesta_externa?ficha=1");
        $("#historial_ficha_" + comentario_id).slideDown();
        return false;
    });
    $("html,body").animate({scrollTop: 101}, 500);

    $('#media, #contenedor_fotos, #arbol').on('click','.paginado-media button:first-of-type, #especies-destacadas button:first-of-type',function(){
        $(this).parent().animate({scrollLeft: "-=600px"}, 250);
    });
    $('#media, #contenedor_fotos, #arbol').on('click','.paginado-media button:last-of-type, #especies-destacadas button:last-of-type',function(){
        $(this).parent().animate({scrollLeft: "+=600px"}, 250);
    });


    $('#modal_clasificacion_completa').on('show.bs.modal', function (event) {
        var button = $(event.relatedTarget);
        var taxonId = button.data('taxon-id');
        var modal = $(this);
        modal.find('.modal-body').load('/explora-por-clasificacion?especie_id='+taxonId+'&fromShow=1', function(){
            $(this).children('header, footer').remove();
            $('#buscador-taxonomico').remove();
        });
    });
    $('.btn-label').tooltip({
        html:true,
        sanitize:false,
        container: 'body',
        placement: 'bottom',
        boundary: 'window'
    });
});