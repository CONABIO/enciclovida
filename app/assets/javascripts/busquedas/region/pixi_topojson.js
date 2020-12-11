var containsPoint = function(polygon, p) {
    var inside = false,
        part, p1, p2, i, j, k, len, len2;
    // ray casting algorithm for detecting if point is in polygon
    for (i = 0, len = polygon.length; i < len; i++) {
        part = polygon[i];

        for (j = 0, len2 = part.length, k = len2 - 1; j < len2; k = j++) {

            p1 = part[j];
            p2 = part[k];

            if (((p1[1] > p.y) !== (p2[1] > p.y)) && (p.x < (p2[0] - p1[0]) * (p.y - p1[1]) / (p2[1] - p1[1]) + p1[0])) {
                inside = !inside;
            }
        }
    }
    return inside;
};

var despliegaRegiones = function () {
    var _pixiGlCore2 = PIXI.glCore;
    PIXI.mesh.MeshRenderer.prototype.onContextChange = function onContextChange() {
        var gl = this.renderer.gl;
        this.shader = new PIXI.Shader(gl, 'attribute vec2 aVertexPosition;\n\nuniform mat3 projectionMatrix;\nuniform mat3 translationMatrix;\n\nvoid main(void)\n{\n    gl_Position = vec4((projectionMatrix * translationMatrix * vec3(aVertexPosition, 1.0)).xy, 0.0, 1.0);\n}\n', 'uniform vec4 uColor;\n\nvoid main(void)\n{\n    gl_FragColor = uColor;\n}\n');
    };

    PIXI.mesh.MeshRenderer.prototype.render = function render(mesh) {
        var renderer = this.renderer;
        var gl = renderer.gl;
        var glData = mesh._glDatas[renderer.CONTEXT_UID];

        if (!glData) {
            renderer.bindVao(null);

            glData = {
                shader: this.shader,
                vertexBuffer: _pixiGlCore2.GLBuffer.createVertexBuffer(gl, mesh.vertices, gl.STREAM_DRAW),
                indexBuffer: _pixiGlCore2.GLBuffer.createIndexBuffer(gl, mesh.indices, gl.STATIC_DRAW)
            };

            // build the vao object that will render..
            glData.vao = new _pixiGlCore2.VertexArrayObject(gl)
                .addIndex(glData.indexBuffer)
                .addAttribute(glData.vertexBuffer, glData.shader.attributes.aVertexPosition, gl.FLOAT, false, 2 * 4, 0);

            mesh._glDatas[renderer.CONTEXT_UID] = glData;
        }

        renderer.bindVao(glData.vao);
        renderer.bindShader(glData.shader);
        glData.shader.uniforms.translationMatrix = mesh.worldTransform.toArray(true);
        glData.shader.uniforms.uColor = PIXI.utils.premultiplyRgba(mesh.tintRgb, 1, glData.shader.uniforms.uColor);
        glData.vao.draw(gl.TRIANGLE_STRIP, mesh.indices.length, 0);
    };

    var tipos_regiones = ["estado", "municipio", "anp"];
    opciones.baseMaps = {};

    // Despliega los titulos de los baseMap vacios para no cargar la pagina de un inicio
    tipos_regiones.forEach(function(tipo_region){
        if (opciones.filtros.tipo_region == tipo_region) {
            opciones.baseMaps.inicial = true;  
            cargaRegion(tipo_region, true);
            opciones.baseMaps.inicial = false;
        } else {
            switch (tipo_region) {
              case "estado":
                control_capas.addBaseLayer(L.tileLayer(""), "División estatal");
                break;
              case "municipio":
                control_capas.addBaseLayer(
                  L.tileLayer(""),
                  "División municipal"
                );
                break;
              case "anp":
                control_capas.addBaseLayer(L.tileLayer(""), "División por ANP");
                break;
            }
        } 
    });
};

var cargaRegion = function(tipo_region, inicial=false)
{
    focus = null;
    mousehover = null;

    getJSON('topojson/' + tipo_region + '.topojson', function (topo) {
        opciones.baseMaps[tipo_region] = (function () {
            var firstDraw = true;
            var prevZoom;
            var pixiContainer = new PIXI.Graphics();
            var alphaScale = d3.scaleLinear()
            var meshAlphaScale = d3.scaleLinear()
            .domain([9, 12])
            .range([0.6, 1]);
            meshAlphaScale.clamp(true);
            var tree = new RBush();
            var doubleBuffering = /iPad|iPhone|iPod/.test(navigator.userAgent) && !window.MSStream;
            var mesh;
            return L.pixiOverlay(function (utils) {
                var zoom = utils.getMap().getZoom();
                var container = utils.getContainer();
                var renderer = utils.getRenderer();
                var project = utils.latLngToLayerPoint;
                var scale = utils.getScale();
                //var invScale = 1 / scale;
                var self = this;
                if (firstDraw) {
                    (function () {
                        topo.arcs.forEach(function (arc) {
                            arc.forEach(function (position) {
                                var proj = project([position[1], position[0]]);
                                position[0] = proj.x;
                                position[1] = proj.y;
                            });
                        });

                        var geojson = topojson.feature(topo, topo.objects.collection);
                        var interiors = topojson.mesh(topo, topo.objects.collection, function (a, b) { return a !== b && a.properties.ref === b.properties.ref });

                        topo = null;
                        prevZoom = zoom;

                        function drawPoly(color, alpha) {
                            return function (poly) {
                                var shape = new PIXI.Polygon(poly[0].map(function (point) {
                                    return new PIXI.Point(point[0], point[1]);
                                }));
                                container.beginFill(color, alpha);
                                container.drawShape(shape);
                                if (poly.length > 1) {
                                    for (var i = 1; i < poly.length; i++) {
                                        var hole = new PIXI.Polygon(poly[i].map(function (point) {
                                            return new PIXI.Point(point[0], point[1]);
                                        }));
                                        container.drawShape(hole);
                                        container.addHole();
                                    }
                                }
                            };
                        }

                        geojson.features.forEach(function (feature, index) {
                            var alpha, color;
                            color = 0xffffff;
                            alpha = 0.3;
                            var bounds;
                            
                            if (feature.geometry.type === 'Polygon') {
                                bounds = L.bounds(feature.geometry.coordinates[0]);
                                drawPoly(color, alpha)(feature.geometry.coordinates);
                            } else if (feature.geometry.type == 'MultiPolygon') {
                                feature.geometry.coordinates.forEach(drawPoly(color, alpha));
                                feature.geometry.coordinates.forEach(function (poly, index) {
                                    if (index === 0) bounds = L.bounds(poly[0]);
                                    else {
                                        poly[0].forEach(function (point) {
                                            bounds.extend(point);
                                        });
                                    }
                                });
                            }

                            tree.insert({
                                minX: bounds.min.x,
                                minY: bounds.min.y,
                                maxX: bounds.max.x,
                                maxY: bounds.max.y,
                                feature: feature
                            });
                        });

                        geojson = null;
                        if (renderer.type === PIXI.RENDERER_TYPE.WEBGL) {
                            (function () {
                                mesh = new PIXI.Container();

                                var memo = Object.create(null);
                                var newIndex = 0;
                                var meshVertices = [];
                                var meshIndices = [];
                                var iMax, iMin;

                                function meshCreate(meshVertices, meshIndices, target, color) {
                                    var partialMesh = new PIXI.mesh.Mesh(null, new Float32Array(meshVertices), null, new Uint16Array(meshIndices));
                                    partialMesh.tint = color;
                                    target.addChild(partialMesh);
                                }
                                function meshCb(polygon) {
                                    if (newIndex > 60000) {
                                        memo = Object.create(null);
                                        meshCreate(meshVertices, meshIndices, mesh, 0x333333);
                                        newIndex = 0;
                                        meshVertices = [];
                                        meshIndices = [];
                                    }
                                    var indices = polygon.map(function (point) {
                                        var key = point[0] + '#' + point[1];
                                        var index = memo[key];
                                        if (index !== undefined) return index;
                                        else {
                                            var index = memo[key] = newIndex++;
                                            meshVertices.push(point[0], point[1]);
                                            return index;
                                        }
                                    });
                                    iMax = polygon.length - 1;
                                    iMin = 0;
                                    meshIndices.push(indices[iMax]);
                                    while (iMax - iMin >= 2) {
                                        meshIndices.push(indices[iMax--], indices[iMin++]);
                                    }
                                    if (iMax === iMin) {
                                        meshIndices.push(indices[iMax], indices[iMax]);
                                    } else meshIndices.push(indices[iMax], indices[iMin], indices[iMin]);
                                }

                                var point2index = {};
                                var vertices = [];
                                var edges = [];
                                interiors.coordinates.forEach(function (arc) {
                                    arc.forEach(function (point, index) {
                                        var key = point[0] + '#' + point[1];
                                        var indexTo;
                                        if (!(key in point2index)) {
                                            indexTo = point2index[key] = vertices.length;
                                            vertices.push(point);
                                        } else {
                                            indexTo = point2index[key];
                                        }
                                        if (index > 0) {
                                            var prevPoint = arc[index - 1];
                                            var indexFrom = point2index[prevPoint[0] + '#' + prevPoint[1]];
                                            if (indexFrom !== indexTo) edges.push([indexTo, indexFrom]);
                                        }
                                    })
                                });

                                graphDraw({ vertices: vertices, edges: edges }, 2 / utils.getScale(9), meshCb, Math.PI);
                                meshCreate(meshVertices, meshIndices, mesh, 0);
                            })();
                        } else {
                            mesh = new PIXI.Graphics();
                            mesh.lineStyle(2 / utils.getScale(12), 0x333333, 1);
                            interiors.coordinates.forEach(function (path) {
                                path.forEach(function (point, index) {
                                    if (index === 0) mesh.moveTo(point[0], point[1]);
                                    else mesh.lineTo(point[0], point[1]);
                                });
                            });
                        }
                        interiors = null;

                        container.addChild(mesh);

                        function findFeature(latlng) {
                            var point = project(latlng);
                            var features = tree.search({
                                minX: point.x,
                                minY: point.y,
                                maxX: point.x,
                                maxY: point.y
                            });
                            for (var i = 0; i < features.length; i++) {
                                var feat = features[i].feature;
                                if (feat.geometry.type === 'Polygon') {
                                    if (containsPoint(feat.geometry.coordinates, point)) return feat;
                                } else {
                                    for (var j = 0; j < feat.geometry.coordinates.length; j++) {
                                        var ring = feat.geometry.coordinates[j];
                                        if (containsPoint(ring, point)) return feat;
                                    }
                                }
                            }
                        }

                        function focusFeature(feat) {
                            if (focus) focus.removeFrom(utils.getMap());
                            if (feat) {
                                focus = L.geoJSON(feat, {
                                    coordsToLatLng: utils.layerPointToLatLng,
                                    style: function (feature) {
                                        return {
                                            fillOpacity: .1,
                                            fillColor: '#FFFFFF',
                                            stroke: true,
                                            color: '#104C5B',
                                            weight: 2,
                                        };
                                    },
                                    interactive: false
                                });
                                focus.addTo(utils.getMap());
                                seleccionaRegion(feat.properties);
                            }
                        }

                        function mouseHoverFeature(feat) {
                            if (mousehover) mousehover.removeFrom(utils.getMap());
                            if (feat) {
                                mousehover = L.geoJSON(feat, {
                                    coordsToLatLng: utils.layerPointToLatLng,
                                    style: function (feature) {
                                        return {
                                            fillOpacity: .1,
                                            fillColor: '#FFFFFF',
                                            stroke: true,
                                            color: 'black',
                                            weight: 2,
                                        };
                                    },
                                    interactive: false
                                });
                                mousehover.addTo(utils.getMap());
                            }
                        }

                        function setSelectedRegion()
                        {
                            function findFeatureById(item)
                            {
                                if (item.feature.properties.region_id == opciones.filtros.region_id)
                                    return true;
                                else return false;
                            }
                            
                            if (opciones.filtros.region_id == undefined) return;
                            let feat = tree.all().find(findFeatureById, opciones.filtros.region_id);
                            if (feat != undefined) focusFeature(feat.feature)
                        }

                        function cleanEventVars() {
                            utils.getMap().off("click");
                            utils.getMap().off("mousemove");
                            if (focus) focus.removeFrom(utils.getMap());
                            if (mousehover) mousehover.removeFrom(utils.getMap());

                            let i = 0;
                            utils.getMap().eachLayer(function(layer){ 
                                i += 1; 
                            });
                        }

                        cleanEventVars();
                        setSelectedRegion();

                        utils.getMap().on('click', function (e) {
                            if (!opciones.pixi.marker) {
                                var feat = findFeature(e.latlng);
                                if (feat != undefined) focusFeature(feat);
                            }
                        });

                        utils.getMap().on('mousemove', L.Util.throttle(function (e) {
                            var feat = findFeature(e.latlng);
                            if (feat) {
                                if (focus == undefined) {
                                    var x = e.originalEvent.x + 10, y = e.originalEvent.y - 40; 
                                    $('#nombre-region-hover').html(feat.properties.nombre_region).css({ 'left': x + 'px', 'top': y + 'px' }).show();
                                    mouseHoverFeature(feat);
                                    L.DomUtil.addClass(self._container, 'leaflet-interactive');
                                    
                                } else {
                                    var index_layer = Object.keys(focus._layers)[0]
                                    var region_id = focus._layers[index_layer].feature.properties.region_id;
                                    
                                    if (region_id == feat.properties.region_id) {
                                        if (mousehover) mousehover.removeFrom(utils.getMap());
                                        L.DomUtil.removeClass(self._container, 'leaflet-interactive');
                                        var x = e.originalEvent.x + 10, y = e.originalEvent.y - 40; 
                                        $('#nombre-region-hover').html(feat.properties.nombre_region).css({ 'left': x + 'px', 'top': y + 'px' }).show();
                                    } else {
                                        var x = e.originalEvent.x + 10, y = e.originalEvent.y - 40; 
                                        $('#nombre-region-hover').html(feat.properties.nombre_region).css({ 'left': x + 'px', 'top': y + 'px' }).show();
                                        mouseHoverFeature(feat);
                                        L.DomUtil.addClass(self._container, 'leaflet-interactive');
                                    }
                                }
                            } else {
                                $('#nombre-region-hover').hide();
                                if (mousehover) mousehover.removeFrom(utils.getMap());
                                L.DomUtil.removeClass(self._container, 'leaflet-interactive');
                            }
                        }, 32));

                        utils.getMap().on('mouseout', L.Util.throttle(function (e) {
                            $('#nombre-region-hover').hide();
                            if (mousehover) mousehover.removeFrom(utils.getMap());
                        }, 32));

                    })();
                }
                firstDraw = false;
                mesh.visible = (zoom >= 4);
                mesh.alpha = meshAlphaScale(zoom);
                prevZoom = zoom;
                renderer.render(container);
            }, pixiContainer, {
                doubleBuffering: doubleBuffering,
                destroyInteractionManager: true
            });
        })();

        // Pone el baseMap en el mapa
        switch (tipo_region) {
            case "estado":
                if (inicial) control_capas.addBaseLayer(opciones.baseMaps[tipo_region], "División estatal");
                opciones.baseMaps[tipo_region].addTo(map);
                break;
            case "municipio":
                opciones.baseMaps[tipo_region].addTo(map);
                break;
            case "anp":
                opciones.baseMaps[tipo_region].addTo(map);
                break;
        }
    });
}

// Cuando cambia este componente, pongo el que actualmente selecciono
$(document).ready(function(){
    map.on('baselayerchange', function(e){
        
        if (opciones.baseMaps.inicial == undefined)
        {
            if (opciones.filtros.tipo_region != undefined) {
                opciones.baseMaps[opciones.filtros.tipo_region].removeFrom(map);
                if (opciones.pixi.tiene_var_iniciales) limpiaMapa();  // Nos aseguramos que cada que escoja una region se limpien los registros
                opciones.pixi.tiene_var_iniciales = false;
                
                // Limpia los valores cuando cambia el baseMap
                opciones.filtros = {};
                $('#region_id').val('');
                $('#especie_id_focus').val('');
                $('#catalogo_id').val('');
                $('#pagina').val('1');
            }

            switch (e.name) {
                case "División estatal":
                    opciones.filtros.tipo_region = 'estado';
                    $('#tipo_region').val('estado');
                    cargaRegion('estado');
                    break;
                case "División municipal":
                    opciones.filtros.tipo_region = 'municipio';
                    $('#tipo_region').val('municipio');
                    cargaRegion('municipio');
                    break;
                case "División por ANP":
                    opciones.filtros.tipo_region = 'anp';
                    $('#tipo_region').val('anp');
                    cargaRegion('anp');
                    break;
            }

            cargaEspecies();
        }
    });
});