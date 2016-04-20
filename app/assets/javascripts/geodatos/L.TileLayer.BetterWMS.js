L.TileLayer.BetterWMS = L.TileLayer.WMS.extend({

    onAdd: function (map) {
        // Triggered when the layer is added to a map.
        //   Register a click listener, then do all the upstream WMS things
        L.TileLayer.WMS.prototype.onAdd.call(this, map);
        map.on('click', this.getFeatureInfo, this);
    },

    onRemove: function (map) {
        // Triggered when the layer is removed from a map.
        //   Unregister a click listener, then do all the upstream WMS things
        L.TileLayer.WMS.prototype.onRemove.call(this, map);
        map.off('click', this.getFeatureInfo, this);
    },

    getFeatureInfo: function (evt) {
        // Make an AJAX request to the server and hope for the best
        var url = this.getFeatureInfoUrl(evt.latlng),
            showResults = L.Util.bind(this.showGetFeatureInfo, this);

        $.ajax({
            url: url,
            success: function (data, status, xhr) {
                var err = typeof data === 'string' ? null : data;

                // console.log(data);
                showResults(err, evt.latlng, data);
            },
            error: function (xhr, status, error) {
                showResults(error);
            }
        });
    },

    getFeatureInfoUrl: function (latlng) {
        // Construct a GetFeatureInfo request URL given a point
        var point = this._map.latLngToContainerPoint(latlng, this._map.getZoom()),
            size = this._map.getSize(),

            params = {
                request: 'GetFeatureInfo',
                service: 'WMS',
                srs: 'EPSG:4326',
                styles: this.wmsParams.styles,
                transparent: this.wmsParams.transparent,
                version: this.wmsParams.version,
                format: this.wmsParams.format,
                bbox: this._map.getBounds().toBBoxString(),
                height: size.y,
                width: size.x,
                layers: this.wmsParams.layers,
                info_format: 'application/json',
                query_layers: this.wmsParams.layers,
                // info_format: 'text/html'
            };

        params[params.version === '1.3.0' ? 'i' : 'x'] = point.x;
        params[params.version === '1.3.0' ? 'j' : 'y'] = point.y;

        return this._url + L.Util.getParamString(params, this._url, true);
    },

    showGetFeatureInfo: function (err, latlng, content){

        if(content.features.length > 0){

            console.log(content.features[0].properties.gridid);
            idGrid = content.features[0].properties.gridid;

            singleCellData = cdata;
            singleCellData['qtype'] = "getGridSpecies";
            singleCellData['idGrid'] = idGrid;
            console.log(singleCellData);


            var popup = L.popup();
            var map = this._map


            $.ajax({
                url : url_trabajo,
                type : 'post',
                data : singleCellData,
                success : function (data){

                    htmltable = createTableFromData(data);
                    popup.setLatLng(latlng).setContent(htmltable).openOn(map);

                },
                error: function( jqXHR ,  textStatus,  errorThrown ){

                    console.log("error: " + textStatus);

                }
            });
        }
    }
});

L.tileLayer.betterWms = function (url, options) {
    return new L.TileLayer.BetterWMS(url, options);
};


function createTableFromData(data){

    json_data = JSON.parse(data);
    // console.log(json_data)

    htmltable = "<div class='myScrollableBlockPopup'><div class='panel panel-primary'><div class='panel-heading'><h3>Scores Especie</h3></div><table class='table table-striped'><thead><tr><th>Especie</th><th>Score</th></tr></thead><tbody>";

    for(i = 0; i<json_data.length; i++){
        // console.log(json_data[i]);

        if(json_data[i].rango == ""){
            htmltable += "<tr><td>" + json_data[i].nom_sp +"</td><td>" + (json_data[i].score).toFixed(2) +"</td></tr>";
        }
    }

    htmltable += "</tbody></table></div>";
    htmltable += "<div class='panel panel-primary'><div class='panel-heading'><h3>Scores Clima</h3></div><table class='table table-striped'><thead><tr><th>Bioclim</th><th>Rango</th><th>Score</th></tr></thead><tbody>"

    for(i = 0; i<json_data.length; i++){
        // console.log(json_data[i]);

        if(json_data[i].nom_sp == ""){

            tag = String(json_data[i].rango).split(":")
            min = tag[0].split(".")[0]
            max = tag[1].split(".")[0]
            htmltable += "<tr><td>" + json_data[i].label +"</td><td>" + min+":"+max +"</td><td>" + (json_data[i].score).toFixed(2) +"</td></tr>";
        }
    }

    htmltable += "</tbody></table></div></div>";

    return htmltable;

}