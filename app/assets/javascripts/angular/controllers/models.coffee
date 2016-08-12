angularApp.directive "typeahead", ->
  restrict: 'A'
  link: (scope, element, attrs) ->
    element.typeahead
      source: availableProperties

angularApp.directive "initFocus", ->
  restrict: 'A'
  link: (scope, element, attrs) ->
    element.focus()

angularApp.service "modellFormService", ->
  propertiesList = modellProperties

  addProperty: ->
    propertiesList.push(name: "", value: "")

  getProperties: ->
    propertiesList

angularApp.controller "ModellFormCtrl", ["$scope", "$http", "modellFormService", ($scope, $http, modellFormService) ->
  $scope.submit = ->
    data =
      name: $("#modell_name").val()
      brand: $("#modell_brand_id").val()
      category: $("#modell_category_id").val()
      modell_group: $("#modell_modell_group_id").val()
      modell_properties: modellFormService.getProperties()
      offer_properties: $("#offer-properties").val()
    successCallback = (data) ->
      window.location.href = data
    $form = $("#model-form")
    method = $form.find("input[name=_method]").val()
    method ||= "POST"
    $http(method: method, url: $form.attr("action"), data: data).success(successCallback)
]

angularApp.controller "ModellFormPropertiesCtrl", ["$scope", "modellFormService", ($scope, modellFormService) ->
  $scope.properties = modellFormService.getProperties()

  $scope.add = ->
    modellFormService.addProperty()
]
