
function addTopoData(opts){
    if (opts.clean) opts.layer.clearLayers();

    opts.layer.addData(opts.topojson);
    opts.layer.addTo(map);

    if (opts.fillColor == undefined) opts.fillColor = '#d8d8d8';
    if (opts.color == undefined) opts.color = '#808080';
    handleLayer(opts);
}

function handleLayer(opts){
    opts.layer.setStyle({
        fillColor : opts.fillColor,
        fillOpacity:.5,
        color: opts.color,
        weight:1,
        opacity:.5
    });
    opts.layer.on({
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