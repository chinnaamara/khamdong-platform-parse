app.factory 'SchemesFactory', () ->
  Parse.initialize "l0JxXhedCkA8D1Z2EKyfG9AMbEF0L8oDW743XI13", "Sz4w7HWy38q4hqrIJxuGVkIGSFa3V0WoqElHKoqW"
  Schemes = Parse.Object.extend 'Schemes'

  createNew = (scheme, callback) ->
    schemes = new Schemes
    schemes.save({schemeCode: scheme.schemeCode, schemeName: scheme.schemeName, departmentName: scheme.departmentName}, {
      success: (object) ->
        callback object
      error: (error) ->
        alert("Error: " + error.message)
    })
    return

  readSchemes = (filterKey, callback) ->
    getQuery = new Parse.Query Schemes
    getQuery.descending "createdAt"
    getQuery.limit filterKey.pageLimit
    getQuery.skip(filterKey.pageLimit * (filterKey.pageNumber - 1))
    getQuery.find({
      success: (result) ->
        callback result
      error: (error) ->
        alert 'Error: ' + error.message
    })
    return

  getCount = (callback) ->
    getQuery = new Parse.Query Schemes
    getQuery.count({ success: (result) -> callback result })
    return

  updateScheme = (data, callback) ->
    updateQuery = new Parse.Query Schemes
    updateQuery.equalTo 'objectId', data.id
    updateQuery.first({
      success: (object) ->
        object.save(null, {
          success: (object) ->
            object.set 'schemeCode', data.schemeCode
            object.set 'schemeName', data.schemeName
            object.set 'departmentName', data.departmentName
            object.save()
            callback object
        })
    })
    return

  deleteScheme = (schemeId, callback) ->
    deleteQuery = new Parse.Query Schemes
    deleteQuery.equalTo 'objectId', schemeId
    deleteQuery.each((object) ->
      object.destroy({
        success: (object) ->
          callback object
      })
    )
    return

  return {
    addNewScheme: createNew
    getSchemes: readSchemes
    getCount: getCount
    updateScheme: updateScheme
    deleteScheme: deleteScheme
  }

app.controller "AddSchemeController", ($scope, SchemesFactory, DataFactory, $rootScope, $location) ->
  $scope.filterKey = {
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

  $scope.getDepartments = ->
    DataFactory.getDepartments((res) ->
      $scope.$apply(() ->
        $scope.departments = res
      )
    )
    return

  $scope.getSchemes = (filterKey) ->
    SchemesFactory.getSchemes(filterKey, (res) ->
      $scope.$apply(() ->
        $scope.schemes = res
      )
    )
    return

  $scope.btnAdd = ->
    if $scope.currentUser.role == 'Admin'
      $scope.modelTitle = 'Add New Scheme'
      $scope.schemeName = ''
      $scope.schemeCode = ''
      $scope.departmentName = ''
      $scope.buttonText = 'Add'
    else
      alert 'You are not authorized!'
    return

  $scope.btnEdit = (scheme) ->
    if $scope.currentUser.role == 'Admin'
      $scope.modelTitle = scheme.id
      $scope.buttonText = 'Update'
      $scope.schemeId = scheme.id
      $scope.schemeCode = scheme._serverData.schemeCode
      $scope.schemeName = scheme._serverData.schemeName
      $scope.departmentName = scheme._serverData.departmentName
    else
      alert 'You are not authorized!'
    return

  $scope.addEditClick = ->
    data =
      schemeCode: $scope.schemeCode
      schemeName: $scope.schemeName
      departmentName: $scope.departmentName
    if $scope.buttonText == 'Add'
      addNewScheme(data)
    else
      data.id = $scope.schemeId
      updateScheme(data)
    return

  addNewScheme = (scheme) ->
    if $scope.currentUser.role == 'Admin'
      SchemesFactory.addNewScheme(scheme, (res) ->
        if res
          $scope.getSchemes($scope.filterKey)
          $scope.NumberOfPages()
        else
          alert 'Scheme not Added.'
      )
    else
      alert 'You are not authorized!'
    return

  updateScheme = (scheme) ->
    if $scope.currentUser.role == 'Admin'
      SchemesFactory.updateScheme(scheme, (res) ->
        if res
          $scope.getSchemes($scope.filterKey)
          $scope.NumberOfPages()
        else
          alert 'Scheme not updated.'
      )
    else
      alert 'You are not authorized!'
    return

  $scope.deleteConformation = (scheme) ->
    if $scope.currentUser.role == 'Admin'
      $scope.deleteSchemeName = scheme._serverData.schemeName
      $scope.deleteSchemeId = scheme.id
    else
      alert 'You are not authorized!'
    return

  $scope.deleteScheme = ->
    if $scope.currentUser.role == 'Admin'
      SchemesFactory.deleteScheme($scope.deleteSchemeId, (res) ->
        $scope.getSchemes($scope.filterKey)
        $scope.NumberOfPages()
      )
    else
      alert 'You are not authorized!'
    return

  $scope.NumberOfPages = () ->
    SchemesFactory.getCount((res) ->
      $scope.$apply(() ->
        $scope.maxNumberOfPages = Math.ceil  res / $scope.filterKey.pageLimit
        $scope.noPrevious = true
        $scope.noNext = $scope.maxNumberOfPages == $scope.filterKey.pageNumber ||  $scope.maxNumberOfPages < 1 ? true : false
      )
    )
    return

  $scope.pageNext = ->
    $scope.filterKey.pageNumber += 1
    $scope.noNext = $scope.filterKey.pageNumber == $scope.maxNumberOfPages ? true : false
    $scope.getSchemes($scope.filterKey)
    $scope.noPrevious = false
    return

  $scope.pageBack = ->
    $scope.filterKey.pageNumber -= 1
    $scope.noPrevious = $scope.filterKey.pageNumber == 1 ? true : false
    $scope.getSchemes($scope.filterKey)
    $scope.noNext = false
    return

  $scope.init()
  $scope.getDepartments()
  $scope.getSchemes($scope.filterKey)
  $scope.NumberOfPages()
  return
