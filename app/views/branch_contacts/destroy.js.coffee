$("#modal").modal("hide")
$("#alert-div").html(<%=render "flash" %>)
$("#alert-div").hide().fadeIn(600).delay(1000).fadeOut(600)

$(".modal-table-partial").html(<%=render partial: "index", locals: { branch_contacts: @branch_contacts } %>)
$("#modal").modal("show")
