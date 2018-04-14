$(document).ready(function(){

    // svg del arbol
    leaft = false;
    root = null;
    var min_zoom = 0.1;
    var max_zoom = 7;
    var zoom = d3.behavior.zoom().scaleExtent([min_zoom,max_zoom]);

    var width = 900,
        height = 500;

    force = d3.layout.force()
        .linkDistance(100)
        .charge(-3000)
        .gravity(.1)
        .size([width, height])
        .on("tick", tick);

    var svg = d3.select("#arbol").append("svg")
        .style("cursor","move")
        .style("border", "2px solid black")
        // Para la responsividad
        .classed("svg-container_tree", true)
        .attr("preserveAspectRatio", "xMinYMin meet")
        .attr("viewBox", "0 -50 1200 100")
        .classed("svg-content-responsive", true);

    var g = svg.append("g");
    link = g.selectAll(".link");
    node = g.selectAll(".node");

    d3.json("/especies/" + TAXON.id + "/arbol_nodo", function(error, json) {
        if (error) throw error;

        root = json;
        max_value = json.especies_inferiores_conteo;
        update();
    });

    zoom.on("zoom", function() {
        g.attr("transform", "translate(" + d3.event.translate + ")scale(" + d3.event.scale + ")");
    });

    svg.call(zoom);


    // svg de simbologia
    var width = 200;
    var height = 500;

    var svg = d3.select("#arbol").append("svg")
        .style("border", "2px solid black")
        // Para la responsividad
        .classed("svg-container_sym", true)
        .attr("preserveAspectRatio", "xMinYMin meet")
        .attr("viewBox", "0 -50 110 100")
        .classed("svg-content-responsive", true);

    // El texto de simbologia
    svg.append("text")
        .attr("dy", ".35em")
        .text("Simbología").attr("x",17).attr("y",-25);

    var symbol = [['R', 'Reino'],['P', 'phylum/división'],['C', 'clase'],
        ['O', 'orden'],['F', 'familia'],['G', 'género'],['E', 'especie']];

    symbol.forEach(function(array, index) {
        symbology(svg, array, index)
    });

    // El nodo con el numero de jemplo #
    var circle_symbol = svg.append("circle")
        .attr("class", "g_sym")
        .attr("r", 10);

    circle_symbol.style("fill", "#C6DBEF")
        .attr("cx", 20)
        .attr("cy", 40*8);

    svg.append("text")
        .attr("dy", ".35em")
        .text("#").attr("x",16).attr("y",40*8-20).attr("class", "sym_text_small");

    svg.append("text")
        .attr("dy", ".35em")
        .attr("font", "9px sans-serif")
        .text("# aproximado").attr("x",10).attr("y",40*8+20).attr("class", "sym_text");

    svg.append("text")
        .attr("dy", ".35em")
        .attr("font", "9px sans-serif")
        .text("de especies").attr("x",10).attr("y",40*8+30).attr("class", "sym_text");

    svg.append("text")
        .attr("dy", ".35em")
        .attr("font", "9px sans-serif")
        .text("en México").attr("x",10).attr("y",40*8+40).attr("class", "sym_text");

});

function update() {
    var nodes = flatten(root),
        links = d3.layout.tree().links(nodes);

    // Restart the force layout.
    force
        .nodes(nodes)
        .links(links)
        .start();

    // Update links.
    link = link.data(links, function(d) { return d.target.id; });
    link.exit().remove();

    link.enter().insert("line", ".node")
        .attr("class", "link");

    // Update nodes.
    node = node.data(nodes, function(d) { return d.id; });
    node.exit().remove();

    var nodeEnter = node.enter().append("g")
        .attr("class", "node")
        .call(force.drag().on("dragstart", dragstart));

    nodeEnter.append("circle")
        .attr("r", function(d) {return d.radius_size;});

    // El numero de especies arriba del nodo
    var conteo_link = nodeEnter.append("text")
        .attr("y", function(d) {return -10 - d.radius_size;})
        .attr("dy", ".35em");

    conteo_link.append("a")
        .attr("xlink:href", function(d){return d.especies_inferiores_url;})
        .text(function(d) { return d.especies_inferiores_conteo == 0 ? '' : d.especies_inferiores_conteo; })
        .attr("class", "link_common_name").attr("target", "_blank");

    // La categoria taxonomica abreviada del taxon
    nodeEnter.append("text")
        .attr("dy", ".35em")
        .text(function(d) { return d.abreviacion_categoria})
        .on("click", click);

    node.select("circle")
        .style("fill", function(d) {return d.color;} )
        .on("click", click);

    // Nombre cientifico
    var scientific_name_link = nodeEnter.append("text")
        .attr("dy", ".35em")
        .attr("x", function(d) {
            // Le aumentamos la distancia del radio para que no se encime
            return size_in_pixels(d, true);
        })
        .attr("y", function(d) {
            if (d.nombre_comun == undefined || d.nombre_comun.length == 0) return 0;
            else return 8;
        });

    scientific_name_link.append("a")
        .attr("xlink:href", function(d) {return "/especies/" + d.especie_id} )
        .text(function(d) { return d.nombre_cientifico;})
        .attr("class", "link_scientific_name");

    var common_name_link = nodeEnter.append("text")
        .attr("dy", ".35em")
        .attr("x", function(d) {
            // Le aumentamos la distancia del radio para que no se encime
            return size_in_pixels(d, false);
        })
        .attr("y", function(d) {
            if (d.nombre_comun == undefined || d.nombre_comun.length == 0) return 0;
            else return -8;
        });

    common_name_link.append("a")
        .attr("xlink:href", function(d) {return "/especies/" + d.especie_id} )
        .text(function(d) {
            if (d.nombre_comun == undefined || d.nombre_comun.length == 0) return '';
            else return d.nombre_comun;
        });
}

function size_in_pixels (d, scientific_name) {
    // Calcula los pixeles de la cadena para una mejor aproximacion
    var canvas = document.createElement('canvas');
    var ctx = canvas.getContext("2d");
    ctx.font = "12px sans-serif";

    if (scientific_name) var text_length = ctx.measureText(d.nombre_cientifico).width;
    else var text_length = ctx.measureText(d.nombre_comun).width;

    // Le aumentamos la distancia del radio para que no se encime
    return (60*text_length)/140 + d.radius_size + 5;
}

function tick() {
    node.attr("transform", function(d) { return "translate(" + d.x + "," + d.y + ")"; });

    link.attr("x1", function(d) { return d.source.x; })
        .attr("y1", function(d) { return d.source.y; })
        .attr("x2", function(d) { return d.target.x; })
        .attr("y2", function(d) { return d.target.y; });
}

// Toggle children on click.
function click(d) {
    if (d3.event.defaultPrevented) return; // ignore drag

    if (d.children)
    {
        console.log(d.children);
        d.children = null;
        leaft = false;
        update();
    } else {

        $.ajax({
            type: 'GET',
            url: "/especies/" + d.especie_id + "/hojas_arbol_nodo",
            dataType: "json"
        }).done(function(data) {
            if (data.length > 0)
            {
                leaft = true;
                d.children = data;
                update();
            }
        });
    }
}

// Returns a list of all nodes under the root.
function flatten(root) {
    var nodes = [], i = 0;

    function recurse(node) {
        if (node.children) node.children.forEach(recurse);

        if (leaft) node.id = ++i;
        else
        if (!node.id) node.id = ++i;

        nodes.push(node);
    }

    recurse(root);
    return nodes;
}

function dragstart(d) {
    d3.event.sourceEvent.stopPropagation();
    d3.select(this).classed("fixed", d.fixed = true);
}

function symbology(svg, array, index) {
    var circle_symbol = svg.append("circle")
        .attr("class", "g_sym")
        .attr("r", 10);

    if (array[0] == 'R')
        var circle_color = '#c27113';
    else if (array[0] == 'E')
        var circle_color = '#748c17';
    else
        var circle_color = '#C6DBEF';

    circle_symbol.style("fill", circle_color)
        .attr("cx", 20)
        .attr("cy", 40*index+20);

    svg.append("text")
        .attr("dy", ".35em")
        .text(array[0]).attr("x",16).attr("y",40*index+20);

    svg.append("text")
        .attr("dy", ".35em")
        .text(array[1]).attr("x",35).attr("y",40*index+20).attr("class", "sym_text");
}