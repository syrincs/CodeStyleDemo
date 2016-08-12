$(".table-partial").html(<%=render partial: "index", locals: { branches: @branches.page(session[:branches_page]) } %>)

fullTableRowClickable()
