window.angularApp = angular.module("myApp", ["flow"])

angularApp.config ["$httpProvider", ($httpProvider) ->
  authToken = $("meta[name=\"csrf-token\"]").attr("content")
  $httpProvider.defaults.headers.common["X-CSRF-TOKEN"] = authToken
]

angularApp.config ["flowFactoryProvider", (flowFactoryProvider) ->
  flowFactoryProvider.defaults =
    chunkSize: 4 * 1024 * 1024
    permanentErrors: [404, 500, 501]
    maxChunkRetries: 1
    chunkRetryInterval: 5000
    simultaneousUploads: 3
    headers: (flowFile, flowChunk) ->
      "X-CSRF-Token": $("meta[name='csrf-token']").attr("content")
]
