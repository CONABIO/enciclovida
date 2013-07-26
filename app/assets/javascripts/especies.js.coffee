# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/


jQuery ->
  oTable = $("#especies").dataTable(
    oLanguage:
      sSearch: "Buca en todos los campos de nombre (comunes o cientificos):"

    sPaginationType: "full_numbers"
    bJQueryUI: "true"
    bProcessing: "true"
    bServerSide: "true"
    sAjaxSource: $("#especies").data("source")
  )

  $("#nombre").keyup ->
    oTable.fnFilter @value, 0

  $("#fuente").keyup ->
    oTable.fnFilter @value, 2

  $("#nombre_autoridad").keyup ->
    oTable.fnFilter @value, 3

  $("#numero_filogenetico").keyup ->
    oTable.fnFilter @value, 4

  $("#cita_nomenclatural").keyup ->
    oTable.fnFilter @value, 5

  $("#sistema_de_clasificacion").keyup ->
    oTable.fnFilter @value, 6

  $("#anotacion").keyup ->
    oTable.fnFilter @value, 7

  $("#estatus").change ->
    oTable.fnFilter $(this).val(), 1

  $("#created_at").change ->
    oTable.fnFilter $(this).val(), 8

  $("#updated_at").change ->
    oTable.fnFilter $(this).val(), 9