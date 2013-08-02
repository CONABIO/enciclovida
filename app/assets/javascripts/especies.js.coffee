# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

fnFormatDetails = (oTable, nTr) ->
  aData = oTable.fnGetData(nTr)
  sOut = "<table cellpadding=\"5\" cellspacing=\"0\" border=\"0\" style=\"padding-left:50px;\">"
  sOut += "<tr><td>Rendering engine:</td><td>" + aData[1] + " " + aData[4] + "</td></tr>"
  sOut += "<tr><td>Link to source:</td><td>Could provide a link here</td></tr>"
  sOut += "<tr><td>Extra info:</td><td>And any further details here (images etc)</td></tr>"
  sOut += "</table>"
  sOut

jQuery ->
  oTable = $("#especies").dataTable(
    oLanguage:
      sSearch: "Buca en todos los campos de nombre (comunes o cientificos):"
      sInfo: "Mostrando rango: _START_ a _END_ de _TOTAL_ resulatdos"
      sInfoEmpty: "La búsqueda no dio ningún resultado."
      sEmptyTable: "No se encontro ningún resultado."
      sInfoFiltered: "(_MAX_ registros totales)."
      sZeroRecords: "No se encontro ningún resultado."
      sProcessing: "Procesando..."
      oPaginate:
        sFirst: "Primera"
        sNext: "Sig."
        sPrevious: "Ant."
        sLast : "Última"
      sLengthMenu: 'Muestra <select>'+
      '<option value="10">10</option>'+
      '<option value="20">20</option>'+
      '<option value="30">30</option>'+
      '<option value="40">40</option>'+
      '<option value="50">50</option>'+
      '<option value="100">100</option>'+
      '<option value="200">200</option>'+
      '</select> resultados por página'

    sScrollY: "500px"
    sPaginationType: "full_numbers"
    bJQueryUI: "true"
    bProcessing: "true"
    bServerSide: "true"
    sAjaxSource: $("#especies").data("source")
    aoColumnDefs: [
      bSortable: false
      aTargets: [ 0, 3, 6 ]
    ]

  )

  $("#id_especie").keyup ->
    oTable.fnFilter @value, 1

  $("#nombre").keyup ->
    oTable.fnFilter @value, 2

  $("#fuente").keyup ->
    oTable.fnFilter @value, 7

  $("#nombre_autoridad").keyup ->
    oTable.fnFilter @value, 8

  $("#numero_filogenetico").keyup ->
    oTable.fnFilter @value, 9

  $("#cita_nomenclatural").keyup ->
    oTable.fnFilter @value, 10

  $("#sistema_de_clasificacion").keyup ->
    oTable.fnFilter @value, 11

  $("#anotacion").keyup ->
    oTable.fnFilter @value, 12

  $("#box_especie").change ->
    oTable.fnFilter $(this).val(), 0

  $("#especies_categoria_taxonomica_id").change ->
    oTable.fnFilter $(this).val(), 3

  $("#estatus").change ->
    oTable.fnFilter $(this).val(), 6

  $("#created_at").change ->
    oTable.fnFilter $(this).val(), 13

  $("#updated_at").change ->
    oTable.fnFilter $(this).val(), 14