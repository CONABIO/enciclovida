function addTopoData(topoData){
    topoLayer.addData(topoData);
    topoLayer.addTo(map);
    topoLayer.eachLayer(handleLayer);
}

function handleLayer(layer){
    var randomValue = Math.random(),
        fillColor = colorScale(randomValue).hex();

    layer.setStyle({
        fillColor : fillColor,
        fillOpacity: 1,
        color:'#555',
        weight:1,
        opacity:.5
    });
    layer.on({
        mouseover : enterLayer,
        mouseout: leaveLayer
    });
}

function enterLayer(){
    var countryName = this.feature.properties.name;
    $countryName.text(countryName).show();

    this.bringToFront();
    this.setStyle({
        weight:2,
        opacity: 1
    });
}

function leaveLayer(){
    $countryName.hide();
    this.bringToBack();
    this.setStyle({
        weight:1,
        opacity:.5
    });
}