angularApp.controller "VideoUploadCtrl", ["$scope", "$attrs", ($scope, $attrs) ->
  $("#modal").on "hide.bs.modal", (e) ->
    $scope.$flow.cancel()

  $scope.uploadStarted = false

  $scope.progressInPercent = (file) ->
    Math.round(file.progress() * 10000) / 100

  $scope.$on "flow::uploadStart", (event) ->
    $scope.uploadStarted = true

  $scope.$on "flow::fileSuccess", (event, $flow, flowFile) ->
    $.getScript($attrs.completedUrl)
]
