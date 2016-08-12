angularApp.controller "VideoLinkCtrl", ["$scope", "$http", "$attrs", ($scope, $http, $attrs) ->
  $scope.formData = {}
  $scope.buttonText = "Submit"
  $scope.inValidation = false
  $scope.serverErrors = {}

  $scope.processForm = ->
    $scope.serverErrors = {}

    $scope.buttonText = "Submitting..."
    $scope.inValidation = true

    promise = $http
      method: "POST"
      url: $attrs.action
      data: $scope.formData

    promise.success (data) ->
      $("#modal").modal("hide")
      $.getScript($attrs.completedUrl)

    promise.error (data) ->
      for field, errors of data
        $scope.form[field].$dirty = true
        $scope.form[field].$setValidity("server", false)
        $scope.serverErrors[field] = errors.join(", ")

    promise.finally ->
      $scope.buttonText = "Submit"
      $scope.inValidation = false
]
