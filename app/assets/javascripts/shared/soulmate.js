/**
 * Funcion para atachar que una caja de texto tenga funcionamiento con soulmate y redis
 * @param tipo_busqueda
 */
var soulmateAsigna = function(tipo_busqueda, elem)
{
    if (elem == undefined)
        var elemento = 'nombre';
    else
        var elemento = elem;

    var render = function(term, data, type, index, id)
    {
        if (I18n.locale == 'es-cientifico')
        {
            var nombres = '<h5> ' + data.nombre_comun + '</h5>' + '<h5><a href="" class="not-active">' + data.nombre_cientifico + ' </a><i>' + data.autoridad + '</i></h5><h5>&nbsp;</h5>';
            return nombres;
        }else{
            data.nombre_cientifico = limpiar(data.nombre_cientifico);
            
            if(data.nombre_comun == null) {
                var nombres = '<a href="" class="not-active">' + data.nombre_cientifico + '</a>';
            }else {
                var nombres = '<b>' + primeraEnMayuscula(data.nombre_comun) + ' </b><sub>' + data.lengua + '</sub><a href="" class="not-active">' + data.nombre_cientifico + '</a>';
            }

            if(data.foto == null) {
                var foto = '<i class="soulmate-img ev1-ev-icon pull-left"></i>';
            }else{
                var foto_url = data.foto;
                var foto = "<i class='soulmate-img pull-left' style='background-image: url(\"" + foto_url + "\")';></i>";
            }

            var iconos = "";
            var ev = '-ev-icon';

            $.each(data.cons_amb_dist, function(i, val){
                if (i == 'no-endemica' || i =='actual') return true;
                iconos = iconos + "<span class='btn-title' tooltip-title='" + val + "'><i class='" + i + ev +"'></i></span>"
            });

            if(data.geodatos != undefined && data.geodatos.length > 0){
                iconos = iconos + "<span class='btn-title' tooltip-title='Tiene datos geográficos'><i class='fa fa-globe'></i></span>";
            }

            if(data.fotos > 0) {
                iconos = iconos + "<span class='btn-title' tooltip-title='Tiene imágenes'><i class='fa fa-photo'></i><sub>" + data.fotos + "</sub></span>";
            }

            return foto + " " + nombres + "<h5 class='soulmate-icons'>" + iconos + "</h5>";
        }
    };

    var select = function(term, data, type)
    {
        $('#' + elemento).val(term);
        $('ul#soulmate').hide();    // esconde el autocomplete cuando escoge uno

        switch (tipo_busqueda){
            case 'avanzada':
                cat_tax_asociadas(data.id);  // despliega las categorias taxonomicas asociadas al taxon
                $('#id').attr('value', data.id); //TODO arreglar el ID id ¬.¬ !>.> pffff
                break;
            case 'peces':
                $('#id').attr('value', data.id);
                bloqueaBusqueda();
                break;
            case 'pmc_new':
                $('#pmc_pez_especie_id').attr('value', data.id);
                break;
            case 'busqueda_region':
                console.log('acaso aca?' + data.id + '-' + data.nom_cientifico + '-')
                $('#especie_id').attr('value', data.id);
                $('#' + elemento).val(data.nombre_cientifico);
                cargaEspecies();
                break;
            case 'soloAsigna':
                $('#id').attr('value', data.id); //TODO arreglar el ID id ¬.¬ !>.> pffff
                break;
            case 'metamares':
                $('#proy_b_especie_id').attr('value', data.id); // feliz?
                break;
            case 'metamares_proy_esp':
                $('#'+elemento.replace('nombre_cientifico','especie_id')).attr('value', data.id);
                break;
            case 'admin/catalogos':
                $('#'+elemento.replace('nombre_cientifico','especie_id')).attr('value', data.id);
                break;
            case 'admin/catalogos/index':
                $('#admin_catalogo_especie_id').val(data.id);
                $('#admin_catalogo_nombre_cientifico').val(data.nombre_cientifico);
                $('#new_admin_catalogo').submit();
                break;
            case 'admin/especie_catalogo':
                if (data.estatus == "válido")
                {
                    $('#admin_especie_catalogo_especie_id').val(data.id);
                    $('#' + elemento).val(data.nombre_cientifico);
                } else {
                    let data_valido = dameTaxonValido(data.id);
                    $('#admin_especie_catalogo_especie_id').val(data_valido.IdNombre);
                    $('#' + elemento).val(data_valido.TaxonCompleto);
                }
                
                break;                
            case 'busquedas/explora-por-clasificacion':
                window.location.replace('/explora-por-clasificacion?especie_id='  + data.id + '&q=' + data.nombre_cientifico);
                break;
            default:
                // Para no pasar por el controlador de busquedas, ir directo a la especie, solo busqueda basica
                var nom_cientifico = data.nombre_cientifico.trim().toLowerCase().replace(/[^a-z0-9]+/g,'-').replace(/(^-|-$)/g,'').replace(/[\(\)]/g, '');
                window.location.replace('/especies/'  + data.id + '-' + nom_cientifico);
                $('#id').attr('value', data.id); //TODO arreglar el ID id ¬.¬ !>.> pffff
        }
    };

    $('#' + elemento).soulmate({
        url:            SITE_URL + "sm/search",
        types:          TYPES,
        renderCallback: render,
        selectCallback: select,
        minQueryLength: 2,
        maxResults:     5,
        timeout:        3500
    });
};

/**
 * Funcion para atachar que una caja de texto tenga funcionamiento con soulmate y redis
 * @elem al elemento al cual se le quiere poner redis
 */
var soulmateRegionAsigna = function(elem)
{
    if (elem == undefined) var elemento = 'region';
    else var elemento = elem;

    var render = function(term, data)
    {
        var html = '<h5>' + data.nombre_region + '</h5>';
        if (data.tipo_region != undefined) html+= "<sub>" + data.tipo_region + "</sub>";

        return html;
    };

    var select = function(term, data, type)
    {
        $('ul#soulmate').hide();  // Esconde el autocomplete cuando escoge uno
        var prop = { region_id: data.region_id, tipo_region: type, nombre_region: data.nombre_region, bounds: data.bounds }
        seleccionaRegion(prop);
    };

    $('#' + elemento).soulmate({
        url:            SITE_URL + "sm/search",
        types:          ['estado','municipio','anp'],
        renderCallback: render,
        selectCallback: select,
        minQueryLength: 2,
        maxResults:     10
    });
};

var dameTaxonValido = function(especie_id)
{
    let data_valio = null

    $.ajax({
            url: "/especies/" + especie_id + '.json',
            async: false,
            success: function(data) {
                data_valido = data
            }
        });
    
    return data_valido;
};