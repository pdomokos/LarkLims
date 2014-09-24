# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

@load_user_filter = ()  ->
  $.ajax '/users',
    type: 'GET'
    dataType: 'json'
    error: (jqXHR, textStatus, errorThrown) ->
      console.log "AJAX Error: #{textStatus}"
    success: (data, textStatus, jqXHR) ->
      console.log "Successful AJAX call"
      console.log data

      i = 0
      $("#user-selection-list").empty()
      for user in data
        new_user = $("#list_useritem_template").clone()
        new_id =  "usr-" + i
        new_user.attr('id', new_id)
        if i == 0
          $("ul#user-selection-list").html(new_user)
        else
          new_user.insertAfter($("ul#user-selection-list").children().last())
        i = i+1

        $("#"+new_id+" div a").html(user.name)
        $("#"+new_id+" div a").attr("id", "findbyuser-button")
        $("#"+new_id+" div a").attr("value", user.id)
        $("#"+new_id+" div a").attr("class", "list-button-link")


@load_orders = (param)  ->
  $("#order-header").removeClass("hidden")
  $("#product-header").addClass("hidden")
  $("#user-header").addClass("hidden")
  if param
    path = '/orders'+param
  else
    path = '/orders'
  console.log param
  $.ajax path,
    type: 'GET'
    dataType: 'json'
    error: (jqXHR, textStatus, errorThrown) ->
      console.log "AJAX Error: #{textStatus}"
    success: (data, textStatus, jqXHR) ->
      console.log "Successful AJAX call"
      console.log data

#      if data[0].num_opened and data[0].num_closed
#        $("#order-stat-open").html("<i class=\"fa fa-arrow-circle-o-up\"></i> "+data[0].num_opened+" Open")
#        $("#order-stat-closed").html("<i class=\"fa fa-check\"></i> "+data[0].num_closed+" Completed")

      i = 0
      $("#orders-table").empty()
      for order in data
        new_order = $("#list_item_template").clone()
        new_id =  "ord-" + i
        new_order.attr('id', new_id)
        if i == 0
          $("ul#orders-table").html(new_order)
        else
          new_order.insertAfter($("ul#orders-table").children().last())
        i = i+1

        $("#"+new_id+" div a.browser-list-cell-title-link").html(order.product_name)
        $("#"+new_id+" div a.browser-list-cell-title-link").attr("href", "/orders/"+order.id)
        $("#"+new_id+" div div.browser-meta span").html(
            "Ordered "+order.order_age+" ago by <a href='/users/"+order.owner_id+"'>"+order.owner+"</a>")

@unselect_meus = () ->
  $("div.browser-subnav div.browser-links a").removeClass('selected')
  $("#orders-title").addClass('hidden')
  $("#orders-table").addClass('hidden')
  $("#products-table").addClass('hidden')
  $("#users-table").addClass('hidden')
  $("#new-order-button").addClass('hidden')
  $("#new-product-button").addClass('hidden')
  $("#new-user-button").addClass('hidden')

@delete_product_params = () ->
  $("#param-container>dl.dynamic").remove()

@add_product_params = (product_id) ->
  $("#param-container>dl.dynamic").remove()
  $("#product-id-holder").val(product_id)
  $.ajax '/products/'+product_id+'/product_params',
    type: 'GET'
    dataType: 'json'
    error: (jqXHR, textStatus, errorThrown) ->
      console.log "AJAX Error: #{textStatus}"
    success: (data, textStatus, jqXHR) ->
      console.log "Successful AJAX call, product params for product "+product_id
      console.log data

      $("<div id=\"params-holder-new\" class=\"hidden\"></div>").insertAfter($("#params-holder"))
      i = 0
      for param in data
        console.log param.key
        new_param = $("#param-template").children().first().clone()
        new_id =  "par-" + i
        new_param.attr('id', new_id)
        $("#params-holder-new").append(new_param)
        $("#"+new_id+">dt >label").html(param.name)
        $("#"+new_id+">dd >input").attr('id', new_id+"-input")
        $("#"+new_id+">dd >input").attr('name', param.id)
        $("#"+new_id+">dt >label").attr("for", new_id+"-input")
        i = i + 1

      $("#params-holder").addClass("hidden")
      $("#params-holder-new").removeClass("hidden")
      $("#params-holder").remove()
      $("#params-holder-new").attr("id", "params-holder")

@browser_menu = () ->
  $("#orders-button").click ->
    unselect_meus()
    $("#orders-title").removeClass('hidden')
    $("#orders-table").removeClass('hidden')
    $("#orders-button").addClass('selected')
    $("#new-order-button").removeClass('hidden')
    $("#new-order-table").addClass("hidden")
    load_orders()

  $("#products-button").click ->
    unselect_meus()
    $("#products-button").addClass('selected')
    $("#products-table").removeClass('hidden')
    $("#new-product-button").removeClass('hidden')
    $("#new-order-table").addClass("hidden")
    load_products()

  $("#users-button").click ->
    unselect_meus()
    $("#users-button").addClass('selected')
    $("#users-table").removeClass('hidden')
    $("#new-user-button").removeClass('hidden')
    $("#new-order-table").addClass("hidden")
    load_users()

  $("#new-order-button").click (event) ->
    event.preventDefault()
    delete_product_params()
    $("#browser-list-header-tab").addClass("hidden")
    $("#orders-table").addClass("hidden")
    $("#products-table").addClass("hidden")
    $("#users-table").addClass("hidden")
    $("#new-order-table").removeClass("hidden")
    $("#product-name-sel").empty()

    $.ajax '/products',
      type: 'GET'
      dataType: 'json'
      error: (jqXHR, textStatus, errorThrown) ->
        console.log "AJAX Error: #{textStatus}"
      success: (data, textStatus, jqXHR) ->
        console.log "Successful AJAX call"
        console.log data

        first_product = -1
        i = 0
        for p in data
          opt_str = "<option value=\""+p.id+"\">"+p.name+"</option>"
          if i == 0
            $("#product-name-sel").html(opt_str)
            first_product = p.id
          else
            $("#product-name-sel").append(opt_str)
          i = i+1
        add_product_params(first_product)

  $("#product-name-sel").change ->
    opt = $(this).find('option:selected');
    console.log opt
    product_id = opt.val()
    add_product_params(product_id)


  $("#new-order-submit-button").click (event) ->
    event.preventDefault()
    values = $("#new-order-form").serialize()
    $.ajax '/orders',
      type: 'POST',
      data: values,
      dataType: 'json'
      error: (jqXHR, textStatus, errorThrown) ->
        console.log "CREATE ORDER AJAX Error: #{textStatus}"

      success: (data, textStatus, jqXHR) ->
        console.log "CREATE ORDER  Successful AJAX call"
        console.log data

        for item in $("#params-holder>dl>dd input")
          param_id = item["name"]
          value = item.value
          $.ajax "/orders/"+data.id+"/product_params/"+param_id,
            async: false,
            type: 'PATCH',
            data: {product_param: { value:  value}},
            dataType: 'json'
            error: (jqXHR, textStatus, errorThrown) ->
              console.log "PATCH ORDER AJAX Error: #{textStatus}"

            success: (data, textStatus, jqXHR) ->
              console.log "PATHCH ORDER  Successful AJAX call"
        window.location.assign( "/pages/browser")

  $("#order-sort-status-button").click () ->
    $("#order-sort-status-menu").removeClass("hidden")
    $("#order-sort-created-by-menu").addClass("hidden")
    $("#order-sort-date-menu").addClass("hidden")

  $("#order-sort-date-button").click () ->
    $("#order-sort-date-menu").removeClass("hidden")
    $("#order-sort-status-menu").addClass("hidden")
    $("#order-sort-created-by-menu").addClass("hidden")

  $("#order-sort-created-by-button").click () ->
    $("#order-sort-created-by-menu").removeClass("hidden")
    $("#order-sort-date-menu").addClass("hidden")
    $("#order-sort-status-menu").addClass("hidden")


  $("#completed-button").click (event) ->
    event.preventDefault()
    
    load_orders("?findbyStatus=1")

  $("#uncompleted-button").click (event) ->
    event.preventDefault()
    load_orders("?findbyStatus=0")

  $("#sortbydate-asc-button").click (event) ->
    event.preventDefault()
    load_orders("?sortbyAsc=order_date")

  $("#sortbydate-desc-button").click (event) ->
    event.preventDefault()
    load_orders("?sortbyDesc=order_date")

  $("body").delegate("#user-selection-list li", "click", () ->
    a_clicked = event.toElement
    load_orders("?findbyId="+a_clicked.getAttribute("value"))
    )

  $("body").delegate("#select-header span", "click", () ->
    $("#order-sort-status-menu").addClass("hidden")
    $("#order-sort-created-by-menu").addClass("hidden")
    $("#order-sort-date-menu").addClass("hidden")
  )

