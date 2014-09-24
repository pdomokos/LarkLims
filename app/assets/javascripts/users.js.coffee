# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

@load_users = (param)  ->
  if param
    path = '/users'+param
  else
    path = '/users'
  console.log param
  $("#user-header").removeClass("hidden")
  $("#order-header").addClass("hidden")
  $("#product-header").addClass("hidden")
  $.ajax path,
    type: 'GET'
    dataType: 'json'
    error: (jqXHR, textStatus, errorThrown) ->
      console.log "AJAX Error: #{textStatus}"
    success: (data, textStatus, jqXHR) ->
      console.log "Successful AJAX call"
      console.log data

      i = 0
      $("#products-table").empty()
      for user in data
        new_user = $("#list_item_template").clone()
        new_id =  "usr-" + i
        new_user.attr('id', new_id)
        if i == 0
          $("ul#users-table").html(new_user)
        else
          new_user.insertAfter($("ul#users-table").children().last())
        i = i+1

        $("#"+new_id+" div a.browser-list-cell-title-link").html(user.name)
        $("#"+new_id+" div a.browser-list-cell-title-link").attr("href", "/users/"+user.id)
        $("#"+new_id+" div div.browser-meta span").html(user.email)

  $("#user-sort-button").click () ->
    $("#user-sort-menu").removeClass("hidden")

  $("#order-by-user-name-button").click (event) ->
    event.preventDefault()
    load_users("?sortbyAsc=name")

  $("#order-by-user-date-button").click (event) ->
    event.preventDefault()
    load_users("?sortbyDesc=created_at")

  $("body").delegate("#select-header span", "click", () ->
    $("#user-sort-menu").addClass("hidden")
  )