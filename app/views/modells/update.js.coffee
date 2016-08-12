$("#modal").modal("hide")
$("#alert-div").html(<%=render "flash" %>)
$("#alert-div").hide().fadeIn(600).delay(1000).fadeOut(600)

if ($("#filter").val() != "")
    $.ajax
      dataType: "html"
      url: <%=modells_path(remote: true)%>
      data:
        filter: $("#filter").val()
      success: (data) ->
        table = $("table#modells")
        table.find("tbody *, tfoot").remove()
        table.append(data)
        fullTableRowClickable()
else
  $(".table-partial").html(<%=render partial: "index", locals: { modells: @modells.page(session[:modells_page]) } %>)

fullTableRowClickable()

