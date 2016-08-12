$("#modal").modal("hide")
$("#alert-div").html(<%=render "flash" %>)
$("#alert-div").hide().fadeIn(600).delay(1000).fadeOut(600)

$("#modal").html(<%=render "form"%>)
$("#modal").modal("show")
