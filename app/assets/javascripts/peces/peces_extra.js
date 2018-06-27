$(document).ready(function(){
    $(".btn-ficha").one('click',function(){
        idEspecie = $(this).data('especie-id');
        pestaña = '/peces/'+idEspecie+'?layout=0';
        $('#datos-'+idEspecie).load(pestaña);
    });
    $("path[id^=path_zonas_]").on('click', function(){
        $(this).toggleClass('zona-seleccionada');
        var input = $('#' + this.id.replace('path_',''));
        console.log(input);
        console.log(input.prop("checked"));
        input.prop("checked", !input.prop("checked"));
        console.log(input.prop("checked"));
    });
});

function limpiaBusqueda(){
    $(".agrupada *, .recomendada *, #nombre").attr("disabled", false).removeClass("disabled");
    $( "#especie_id, #nombre" ).val('');
};


/*/ Estandarizar en la centralizacion */

function firstToUpperCase( str ) {
    return str.substr(0, 1).toUpperCase() + str.substr(1);
}

var soulmate_asigna = function()
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
            if (data.fotos > 0){iconos = iconos + "<i class='picture-ev-icon text-success' title='Tiene imÃ¡genes'></i><sub>" + data.fotos + "</sub>"}

            return foto + " " + nombres + "<h5 class='soulmate-icons'>" + iconos + "</h5>";
        }
    };

    var select = function(term, data, type)
    {
        $('#nombre').val(term);
        $( "#especie_id" ).val(data.id);
        $('ul#soulmate').hide();    // esconde el autocomplete cuando escoge uno
        $( ".agrupada select, .recomendada select, .recomendada input, .recomendada span" ).attr('disabled', true).addClass('disabled');
    };

    $('#nombre').soulmate({
        url:            "http://"+ IP + ":" + PORT + "sm/search",
        types:          ['peces'],
        renderCallback: render,
        selectCallback: select,
        minQueryLength: 2,
        maxResults:     5
    });
};
