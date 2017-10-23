
function addTopoData(topoData){
    topoLayer.clearLayers();
    topoLayer.addData(topoData);
    topoLayer.addTo(map);
    handleLayer(topoLayer);
}

function handleLayer(layer){
    layer.setStyle({
        fillColor : '#99FF99',
        fillOpacity:.5,
        color:'#2d4c2d',
        weight:1,
        opacity:.5
    });
    layer.on({
        mouseover : enterLayer,
        mouseout: leaveLayer
    });
}

function enterLayer(){
    this.bringToFront();
    this.setStyle({
        weight:3,
        opacity:.5,
        color: '#2d4c2d'
    });
}

function leaveLayer(){
    this.bringToBack();
    this.setStyle({
        weight:1,
        opacity:.5
    });
}