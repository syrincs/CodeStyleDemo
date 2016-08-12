$("#modal").modal("hide")
$("#alert-div").html(<%=render "flash" %>)
$("#alert-div").hide().fadeIn(600).delay(1000).fadeOut(600)

$(".table-partial").html(<%=render partial: "brands/modells", locals: { brand_modells: @brand_modells.page(session[:brand_modells_page]) } %>)

fullTableRowClickable()
