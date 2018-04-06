/*
 Cuando el usuario elige un taxon en la vists avanzada, las categorias
 taxonimicas se despliegan segun las asociadas
 */
function firstToUpperCase( str ) {
    return str.substr(0, 1).toUpperCase() + str.substr(1);
}

var por_nombre = function()
{
    $("#id").val("");
    $("#datos_cat").html("");
    $("#panelCategoriaTaxonomicaPt").hide();

    $("[id^='id_']").each(function(){
        $(this).prop('checked', false);
    });

    $('#por_gi, #por_nombre_fuente, #por_gi_fuente, #por_nombre').toggle('easeOutBounce');
};

var por_gi = function()
{
    $("#id").val("");
    $("#nombre").val('');
    $("#datos_cat").html("");
    $("#panelCategoriaTaxonomicaPt").hide();

    $('#por_gi, #por_nombre_fuente, #por_gi_fuente, #por_nombre').toggle('easeOutBounce');
};

var cat_tax_asociadas = function(id,nivel,cat)
{
    $.ajax(
        {
            url: "/cat_tax_asociadas",
            type: 'GET',
            data: {
                id: id,
                nivel: nivel,
                cat: cat
            }
        }).done(function(html)
        {
            $('#datos_cat').html('').html(html);
            $('#panelCategoriaTaxonomicaPt').show();
        });
};

var scrolling_page = function(objeto, por_pagina, url)
{
    $(objeto).scrollPagination({
        nop     : por_pagina, // The number of posts per scroll to be loaded
        offset  : 2, // Initial offset, begins at 0 in this case
        error   : '', // When the user reaches the end this is the message that is
        // displayed. You can change this if you want.
        delay   : 500, // When you scroll down the posts will load after a delayed amount of time.
                       // This is mainly for usability concerns. You can alter this as you see fit
        scroll  : true, // The main bit, if set to false posts will not load as the user scrolls.
        // but will still load if the user clicks.
        url     : url
    });
};

var soulmate_asigna = function(tipo_busqueda)
{
    var render = function(term, data, type, index, id)
    {
        if (I18n.locale == 'es-cientifico')
        {
            var nombres = '<h5> ' + data.nombre_comun + '</h5>' + '<h5><a href="" class="not-active">' + data.nombre_cientifico + ' </a><i>' + data.autoridad + '</i></h5><h5>&nbsp;</h5>';
            return nombres;

        } else {
            if (data.nombre_comun == null)
                var nombres = '<a href="" class="not-active">' + data.nombre_cientifico +'</a>';
            else
                var nombres = '<b>' + firstToUpperCase(data.nombre_comun) + ' </b><sub>(' + data.lengua + ')</sub><a href="" class="not-active">' + data.nombre_cientifico +'</a>';


            if (data.foto == null)
                var foto = '<i class="soulmate-img ev1-ev-icon pull-left"></i>';
            else {
                var foto_url = data.foto;
                var foto = "<i class='soulmate-img pull-left' style='background-image: url(\"" + foto_url + "\")';></i>";
            }

            var iconos = "";
            var ev = '-ev-icon';

            $.each(data.cons_amb_dist, function(i, val){
                if (val == 'no-endemica' || val =='actual'){return true}
                iconos = iconos + "<i class='" + val + ev +"' title='"+firstToUpperCase(val)+"'></i>"
            });

            if (data.geodatos != undefined && data.geodatos.length > 0){iconos = iconos + "<i class='glyphicon glyphicon-globe text-success' title='Tiene mapa'></i>"}
            if (data.fotos > 0){iconos = iconos + "<i class='picture-ev-icon text-success' title='Tiene imágenes'></i><sub>" + data.fotos + "</sub>"}

            return foto + " " + nombres + "<h5 class='soulmate-icons'>" + iconos + "</h5>";
        }
    };

    var select = function(term, data, type)
    {
        $('#nombre').val(term);
        $('#id').attr('value', data.id); //TODO arreglar el ID id ¬.¬ !>.> pffff
        $('ul#soulmate').hide();    // esconde el autocomplete cuando escoge uno

        if (tipo_busqueda != undefined && tipo_busqueda == 'avanzada')
            cat_tax_asociadas(data.id);  // despliega las categorias taxonomicas asociadas al taxon
        else {
            // Para no pasar por el controlador de busquedas, ir directo a la especie, solo busqueda basica
            window.location.replace('/especies/' + data.id)
        }
    };

    $('#nombre').soulmate({
        url:            "http://"+ IP + ":" + PORT + "sm/search",
        types:          TYPES,
        renderCallback: render,
        selectCallback: select,
        minQueryLength: 2,
        maxResults:     5
    });
};

$(document).ready(function()
{
    $(document).on('change', ".radio input", function()
    {
        // El ID del grupo iconico
        var id_gi = $(this).val();
        $('#id').val(id_gi);
        cat_tax_asociadas(id_gi,'','');
    });

    $(document).on('click', '#limpiar', function(){
        window.location.href = "/avanzada";
    });

    $(document).on('click', '#por_nombre_fuente', function(){
        por_nombre();
        return false;
    });

    $(document).on('click', '#por_gi_fuente', function(){
        por_gi();
        return false;
    });

    $(document).on('click', '#boton_checklist', function(){
        var url = $(this).attr('url');

        if (url == "") return false;
        else window.open(url, '_blank');
    });


    $("#busqueda_avanzada").on('submit', '#b_avanzada', function() {
        $("#por_gi :input").attr("disabled", true);  // Deshabilita los grupos iconicos para que los repita en la URI
    });
});

