app.factory 'DashboardFactory', ($http) ->
  Parse.initialize "l0JxXhedCkA8D1Z2EKyfG9AMbEF0L8oDW743XI13", "Sz4w7HWy38q4hqrIJxuGVkIGSFa3V0WoqElHKoqW"

  getCount = (filterKey, callback) ->
    getQuery = new Parse.Query 'Grievances'
    getQuery.equalTo filterKey.columnName, filterKey.queryValue
    getQuery.count({ success: (result) -> callback result })
    return

  getGrievances = (filterKey, callback) ->
    getQuery = new Parse.Query 'Grievances'
    getQuery.equalTo filterKey.columnName, filterKey.queryValue
    getQuery.limit filterKey.pageLimit
    getQuery.skip(filterKey.pageLimit * (filterKey.pageNumber - 1))
    getQuery.find({
      success: (result) ->
        callback result
      error: (error) ->
        alert 'Error: ' + error.message
    })
    return

  return {
    retrieveGrievances: getGrievances
    getCount: getCount
  }

app.controller 'DashboardController', ($scope, DashboardFactory, DetailsFactory, DataFactory, $rootScope, $location) ->
  $scope.filterKey = {
    columnName: undefined
    queryValue: undefined
    pageNumber: 1
    pageLimit: 8
  }

  $scope.init = ->
    $scope.currentUser = $.parseJSON(localStorage.getItem 'Parse/l0JxXhedCkA8D1Z2EKyfG9AMbEF0L8oDW743XI13/currentUser')
    if $scope.currentUser
      $rootScope.userName = $scope.currentUser.username
      $scope.currentUser.role = localStorage.getItem 'role'
      $rootScope.administrator = $scope.currentUser.role == 'Admin'
      $rootScope.superUser = $scope.currentUser.role == 'Super User'
      $scope.currentUser.ward = localStorage.getItem 'ward'
    else
      $location.path '/error'
    return

  $scope.getWards = ->
    DataFactory.getWards((res) ->
      $scope.$apply(() ->
        $scope.wards = res
      )
    )
    return

  $scope.NumberOfPages = (filterKey) ->
    DashboardFactory.getCount(filterKey, (res) ->
      $scope.$apply(() ->
        $scope.noRecords = res == 0 ? true : false
        $scope.maxNumberOfPages = Math.ceil  res / $scope.filterKey.pageLimit
        $scope.noPrevious = true
        $scope.noNext = $scope.maxNumberOfPages == $scope.filterKey.pageNumber ||  $scope.maxNumberOfPages < 1 ? true : false
      )
    )
    return

  $scope.getGrievances = (filterKey) ->
#    console.log filterKey
    DashboardFactory.retrieveGrievances(filterKey, (res) ->
      $scope.$apply(() ->
        $scope.grievances = res
        $scope.loading = false
        $scope.loadDone = true
      )
    )
    return

  $scope.showDetails = (details) ->
    if $scope.currentUser.role == 'Admin'
      DetailsFactory.retrieveGrievance = details
      $location.path '/details'
    else
      alert 'You are not authorized!'
    return

  $scope.filterGrievances = (selectedWard) ->
    if $scope.currentUser.role == 'Admin'
      $scope.filterKey.columnName = 'ward'
      $scope.filterKey.queryValue = selectedWard
      $scope.filterKey.pageNumber = 1
      $scope.NumberOfPages($scope.filterKey)
      $scope.getGrievances($scope.filterKey)
    else
      alert 'You are not authorized!'
    return

  $scope.pageNext = ->
    $scope.filterKey.pageNumber += 1
    $scope.noNext = $scope.filterKey.pageNumber == $scope.maxNumberOfPages ? true : false
    $scope.getGrievances($scope.filterKey)
    $scope.noPrevious = false
    return

  $scope.pageBack = ->
    $scope.filterKey.pageNumber -= 1
    $scope.noPrevious = $scope.filterKey.pageNumber == 1 ? true : false
    $scope.getGrievances($scope.filterKey)
    $scope.noNext = false
    return

  $scope.searchResult = (searchKey) ->
    if $scope.currentUser.role == 'Admin'
      $scope.filterKey.pageNumber = 1
      if searchKey
        $scope.filterKey.columnName = 'phoneNumber'
        $scope.filterKey.queryValue = searchKey
      else
        $scope.filterKey.columnName = undefined
        $scope.filterKey.queryValue = undefined
      $scope.NumberOfPages($scope.filterKey)
      $scope.getGrievances($scope.filterKey)
    else
      alert 'You are not authorized!'
    return

  $scope.init()
  $scope.getGrievances $scope.filterKey
  $scope.NumberOfPages $scope.filterKey
  $scope.getWards()
  $scope.loading = true
  $scope.noPrevious = true

  $scope.showDocuments = (data) ->
    if $scope.currentUser.role == 'Admin'
      $scope.noDocs = false
      if data._serverData.recommendedDoc
        $scope.recommendedDoc = true
        canvas1 = document.getElementById "recommendedDocCanvas"
        ctx1 = canvas1.getContext("2d")
        img1 = new Image()
        img1.onload = ->
          ctx1.drawImage(this, 0, 0, canvas1.width, canvas1.height)
        img1.src = "data:image/gif;base64," + data._serverData.recommendedDoc
        document.getElementById("downloadrecommendedDoc").href = "data:image/png;base64," + data._serverData.recommendedDoc
        document.getElementById("downloadrecommendedDoc").download = 'recommended_doc.png'
      else
        $scope.recommendedDoc = false

      if data._serverData.coiDoc
        $scope.COIDoc = true
        canvas2 = document.getElementById "COIDocCanvas"
        ctx2 = canvas2.getContext("2d")
        img2 = new Image()
        img2.onload = ->
          ctx2.drawImage(this, 0, 0, canvas2.width, canvas2.height)
        img2.src = "data:image/gif;base64," + data._serverData.coiDoc
        document.getElementById("downloadCOIDoc").href = "data:image/png;base64," + data._serverData.coiDoc
        document.getElementById("downloadCOIDoc").download = 'coi.png'
      else
        $scope.COIDoc = false

      if data._serverData.voterCard
        $scope.voterDoc = true
        canvas3 = document.getElementById "voterIdCanvas"
        ctx3 = canvas3.getContext("2d")
        img3 = new Image()
        img3.onload = ->
          ctx3.drawImage(this, 0, 0, canvas3.width, canvas3.height)
        img3.src = "data:image/gif;base64," + data._serverData.voterCard
        document.getElementById("downloadVoter").href = "data:image/png;base64," + data._serverData.voterCard
        document.getElementById("downloadVoter").download = 'voter.png'
      else
        $scope.voterDoc = false

      if data._serverData.casteCertificate
        $scope.casteDoc = true
        canvas4 = document.getElementById "casteCertificateCanvas"
        ctx4 = canvas4.getContext("2d")
        img4 = new Image()
        img4.onload = ->
          ctx4.drawImage(this, 0, 0, canvas4.width, canvas4.height)
        img4.src = "data:image/gif;base64," + data._serverData.casteCertificate
        document.getElementById("downloadCasteCertificate").href = "data:image/png;base64," + data._serverData.casteCertificate
        document.getElementById("downloadCasteCertificate").download = 'caste.png'
      else
        $scope.casteDoc = false

      if data._serverData.otherDoc
        $scope.otherDoc = true
        canvas5 = document.getElementById "otherDocCanvas"
        ctx5 = canvas5.getContext("2d")
        img5 = new Image()
        img5.onload = ->
          ctx5.drawImage(this, 0, 0, canvas5.width, canvas5.height)
        img5.src = "data:image/gif;base64," + data._serverData.otherDoc
        document.getElementById("downloadOther").href = "data:image/png;base64," + data._serverData.otherDoc
        document.getElementById("downloadOther").download = 'other_doc.png'
      else
        $scope.otherDoc = false

      if ! data._serverData.recommendedDoc && ! data._serverData.aadharCard && ! data._serverData.voterCard && ! data._serverData.sscCertificate && ! data._serverData.otherDoc
        $scope.noDocs = true
    else
      alert 'You are not authorized!'
    return
  return
