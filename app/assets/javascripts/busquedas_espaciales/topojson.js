
function addTopoData(topoData, layer, clean){
    if (clean) layer.clearLayers();
    layer.addData(topoData);
    layer.addTo(map);
    handleLayer(layer);
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
        opacity:.5
    });
}

function leaveLayer(){
    this.bringToBack();
    this.setStyle({
        weight:1,
        opacity:.5
    });
}