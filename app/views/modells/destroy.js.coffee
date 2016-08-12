$("#modal").modal("hide")
$("#alert-div").html(<%=render "flash" %>)
$("#alert-div").hide().fadeIn(600).delay(1000).fadeOut(600)

$(".table-partial").html(<%=render partial: "index", locals: { modells: @modells.page(session[:modells_page]) } %>)

fullTableRowClickable()
