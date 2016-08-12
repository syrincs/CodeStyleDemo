angularApp.directive "showErrors", ->
  restrict: "A"
  require: "form"
  link: (scope, el, attrs, formCtrl) ->
    $(el).find(".form-group").each ->
      formGroup = $(@)
      formGroup.find("input, select, textarea").each ->
        input = $(@)
        formField = formCtrl[input.attr("name")]
        input.on "change, focus, blur, input", ->
          scope.$apply ->
            formField.$setValidity("server", true)
            input.closest(".form-group").toggleClass("has-error", formField.$invalid)

    updateOnServerErrorsChange = ->
      $(el).find(".form-group").each ->
        formGroup = $(@)
        formGroup.find("input, select, textarea").each ->
          input = $(@)
          formField = formCtrl[input.attr("name")]
          input.closest(".form-group").toggleClass("has-error", formField.$dirty && formField.$invalid)

    scope.$watch "serverErrors", updateOnServerErrorsChange, true
