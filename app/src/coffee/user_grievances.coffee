app.factory 'GrievancesFactory', () ->
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
    getGrievances: getGrievances
    getCount: getCount
  }

app.controller 'GrievancesController', ($scope, $location, GrievancesFactory, EditGrievanceFactory, $rootScope) ->
  $scope.filterKey = {
    columnName: 'ward'
    pageNumber: 1
    pageLimit: 4
  }

  $scope.init = ->
    $scope.currentUser = $.parseJSON(localStorage.getItem 'Parse/l0JxXhedCkA8D1Z2EKyfG9AMbEF0L8oDW743XI13/currentUser')
    if $scope.currentUser
      $rootScope.userName = $scope.currentUser.username
      $scope.currentUser.role = localStorage.getItem 'role'
      $rootScope.administrator = $scope.currentUser.role == 'Admin'
      $rootScope.superUser = $scope.currentUser.role == 'Super User'
      $scope.currentUser.ward = localStorage.getItem 'ward'
      $scope.filterKey.queryValue = $scope.currentUser.ward
    else
      $location.path '/error'
#    $scope.$emit 'LOAD'
    return

  $scope.NumberOfPages = (filterKey) ->
    GrievancesFactory.getCount(filterKey, (res) ->
      $scope.$apply(() ->
        $scope.noRecords = res == 0 ? true : false
        $scope.maxNumberOfPages = Math.ceil  res / $scope.filterKey.pageLimit
        $scope.noPrevious = true
        $scope.noNext = $scope.maxNumberOfPages == $scope.filterKey.pageNumber ||  $scope.maxNumberOfPages < 1 ? true : false
      )
    )
    return

  $scope.getGrievances = (filterKey) ->
    GrievancesFactory.getGrievances(filterKey, (res) ->
      $scope.$apply(() ->
        $scope.grievances = res
#        $scope.$emit 'UNLOAD'
        $scope.loading = false
        $scope.loadDone = true
      )
    )
    return

  $scope.showDetails = (data) ->
    $scope.grievanceById = data
    return

  $scope.viewPdf = ->
    $scope.printElement(document.getElementById 'printThis')
    window.print()
    return

  $scope.printElement = (elem) ->
    domClone = elem.cloneNode true
    printSection = document.getElementById 'printSection'
    unless printSection
      printSection = document.createElement 'div'
      printSection.id = 'printSection'
      document.body.appendChild printSection
    printSection.innerHTML = ''
    printSection.appendChild domClone
    return

  $scope.editDetails = (grievance) ->
    EditGrievanceFactory.retrieveGrievance = grievance
    $location.path '/grievance/edit'
    return

  $scope.filterGrievances = ->
    $scope.searchKey = ''
    if $scope.columnName == 'submittedUser'
      $scope.pageTitle = $scope.currentUser.username
      $scope.filterKey.columnName = $scope.columnName
      $scope.filterKey.pageNumber = 1
      $scope.filterKey.queryValue = $scope.currentUser.username
    else
      $scope.filterKey.columnName = 'ward'
      $scope.filterKey.pageNumber = 1
      $scope.filterKey.queryValue = $scope.currentUser.ward
      $scope.pageTitle = $scope.currentUser.ward
    $scope.NumberOfPages($scope.filterKey)
    $scope.getGrievances($scope.filterKey)
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

  $scope.searchResult = ->
    $scope.filterKey.pageNumber = 1
    if $scope.searchKey
      $scope.filterKey.columnName = 'phoneNumber'
      $scope.filterKey.queryValue = $scope.searchKey
    else
      $scope.filterKey.columnName = 'ward'
      $scope.filterKey.queryValue = $scope.currentUser.ward
    $scope.NumberOfPages($scope.filterKey)
    $scope.getGrievances($scope.filterKey)
    return

  $scope.init()
  $scope.getGrievances($scope.filterKey)
  $scope.NumberOfPages($scope.filterKey)
  $scope.noPrevious = true
  $scope.loading = true
  $scope.pageTitle = $scope.currentUser.ward
#  $scope.$on 'LOAD', () -> $scope.loading = true
#  $scope.$on 'UNLOAD', () -> $scope.loading = false
  return
