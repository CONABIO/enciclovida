//= require photo_selectors

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
        window.open("/especies/"+TAXON.id+".pdf?from="+cual_ficha,'_blank');
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

    $('#pestañas').tabs(); // Inicia los tabs

    $('#pestañas > .nav a').click(function(){
        $('#pestañas > .nav li').removeClass("active");
        $(this).parent().addClass("active");
    }).one('click',function(){
        if (!Boolean($(this).hasClass('noLoad'))){
            idPestaña = this.getAttribute('href');
            pestaña = '/especies/'+TAXON.id+'/'+idPestaña.replace('#','');
            $(idPestaña).load(pestaña);
        }
    });

    // Inicia los proveedores de fotos
    $('#edit_photos_dialog').dialog({
        modal: true,
        title: 'Escoge las fotos para este grupo o especie',
        autoOpen: false,
        width: 700,
        open: function( event, ui ) {
            $('#edit_photos_dialog').loadingShades('Cargando...', {cssClass: 'smallloading'});
            $('#edit_photos_dialog').load('/especies/'+TAXON.id+'/edit_photos', function(){
                var photoSelectorOptions = {
                    defaultQuery: TAXON.nombre_cientifico,
                    skipLocal: true,
                    baseURL: '/conabio/photo_fields',
                    taxon_id: TAXON.id,
                    urlParams: {
                        authenticity_token: $('meta[name=csrf-token]').attr('content'),
                        limit: 14
                    },
                    afterQueryPhotos: function(q, wrapper, options) {
                        $(wrapper).imagesLoaded(function() {
                            $('#edit_photos_dialog').centerDialog()
                        })
                    }
                };

                $('.tabs', this).tabs({
                    beforeActivate: function( event, ui ) {
                        if ($(ui.newPanel).attr('id') == 'flickr_taxon_photos' && !$(ui.newPanel).hasClass('loaded')) {
                            //$('.taxon_photos', ui.newPanel).photoSelector(photoSelectorOptions)
                            $('.taxon_photos', ui.newPanel).photoSelector(
                                $.extend(true, {}, photoSelectorOptions, {baseURL: '/flickr/photo_fields'})
                            )
                        } else if ($(ui.newPanel).attr('id') == 'inat_obs_taxon_photos' && !$(ui.newPanel).hasClass('loaded')) {
                            $('.taxon_photos', ui.newPanel).photoSelector(
                                $.extend(true, {}, photoSelectorOptions, {baseURL: '/taxa/'+TAXON.id+'/observation_photos'})
                            )
                        } else if ($(ui.newPanel).attr('id') == 'eol_taxon_photos' && !$(ui.newPanel).hasClass('loaded')) {
                            $('.taxon_photos', ui.newPanel).photoSelector(
                                $.extend(true, {}, photoSelectorOptions, {baseURL: '/eol/photo_fields'})
                            )
                        } else if ($(ui.newPanel).attr('id') == 'wikimedia_taxon_photos' && !$(ui.newPanel).hasClass('loaded')) {
                            $('.taxon_photos', ui.newPanel).photoSelector(
                                $.extend(true, {}, photoSelectorOptions, {baseURL: '/wikimedia_commons/photo_fields'})
                            )
                        } else if ($(ui.newPanel).attr('id') == 'conabio_taxon_photos' && !$(ui.newPanel).hasClass('loaded')) {
                            $('.taxon_photos', ui.newPanel).photoSelector(
                                $.extend(true, {}, photoSelectorOptions, {taxon_id: TAXON.id, baseURL: '/conabio/photo_fields'})
                            )
                        }

                        $(ui.newPanel).addClass('loaded')
                        $('#edit_photos_dialog').centerDialog()
                    },
                    create: function( event, ui) {
                        $('.taxon_photos', ui.panel).photoSelector(photoSelectorOptions);
                        $(ui.panel).addClass('loaded')
                        $('#edit_photos_dialog').centerDialog()
                    }
                })
            })
        }
    });
});