var dameUrlServicioSnibFicha = function(prop)
{
    var snib_url = prop.snib_url + '/snib/getSpecies/' + prop.reino + '/' + prop.catalogo_id + '/?apiKey=enciclovida';
    return snib_url;
};