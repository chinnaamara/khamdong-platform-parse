app.factory 'WardsFactory', () ->
  Parse.initialize "l0JxXhedCkA8D1Z2EKyfG9AMbEF0L8oDW743XI13", "Sz4w7HWy38q4hqrIJxuGVkIGSFa3V0WoqElHKoqW"

  Wards = Parse.Object.extend 'Wards'
  createWard = (wardName, callback) ->
    wards = new Wards()
    wards.save({wardName: wardName}, {
      success: (object) ->
        callback(object)
      error: (error) ->
        alert("Error: " + error.message)
    })
    return


  getWards = (filterKey, callback) ->
    getQuery = new Parse.Query Wards
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
    getQuery = new Parse.Query Wards
    getQuery.count({ success: (result) -> callback result })

  updateWard = (data, callback) ->
    updateQuery = new Parse.Query Wards
    updateQuery.equalTo 'objectId', data.id
    updateQuery.first({
      success: (object) ->
        object.save(null, {
          success: (object) ->
            object.set 'wardName', data.wardName
            object.save()
            callback object
        })
    })
    return

  deleteWard = (wardId, callback) ->
    deleteQuery = new Parse.Query Wards
    deleteQuery.equalTo 'objectId', wardId
    deleteQuery.each((object) ->
      object.destroy({
        success: (object) ->
          callback object
      })
    )
    return

  return {
    getWards: getWards
    createWard: createWard
    getCount: getCount
    updateWard: updateWard
    deleteWard: deleteWard
  }

app.controller 'WardsController', ($scope, $rootScope, WardsFactory, $location) ->
  $scope.filterKey = {
    pageNumber: 1
    pageLimit: 6
  }

  $scope.init = ->
    $scope.currentUser = $.parseJSON(localStorage.getItem 'Parse/l0JxXhedCkA8D1Z2EKyfG9AMbEF0L8oDW743XI13/currentUser')
    if $scope.currentUser
      $rootScope.userName = $scope.currentUser.username
      role = $scope.currentUser.role
      $rootScope.administrator = role == 'Admin'
      $rootScope.superUser = role == 'Super User'
    else
      $location.path '/error'
    return

  $scope.getWards = (filterKey) ->
    WardsFactory.getWards(filterKey, (res) ->
      $scope.$apply(() ->
        $scope.wards = res
      )
    )

  $scope.btnAdd = ->
    $scope.modelTitle = 'Add New Ward'
    $scope.wardName = ''
    $scope.buttonText = 'Add'
    return

  $scope.btnEdit = (ward) ->
    $scope.modelTitle = ward.id
    $scope.buttonText = 'Update'
    $scope.wardId = ward.id
    $scope.wardName = ward._serverData.wardName
    return

  $scope.addEditClick = ->
    data =
      wardName: $scope.wardName
    if $scope.buttonText == 'Add'
      addNewWard(data)
    else
      data.id = $scope.wardId
      updateWard(data)
    return

  addNewWard = (ward) ->
    WardsFactory.createWard(ward.wardName, (res) ->
      if res
        $scope.getWards($scope.filterKey)
        $scope.NumberOfPages()
      else
        console.log 'Ward not added.'
    )
    return

  updateWard = (ward) ->
    WardsFactory.updateWard(ward, (res) ->
      if res
        $scope.getWards($scope.filterKey)
        $scope.NumberOfPages()
      else
        alert 'Ward not updated.'
    )
    return

  $scope.deleteConformation = (ward) ->
    $scope.deleteWardName = ward._serverData.wardName
    $scope.deleteWardId = ward.id
    return

  $scope.deleteWard = ->
    WardsFactory.deleteWard($scope.deleteWardId, (res) ->
      $scope.getWards($scope.filterKey)
      $scope.NumberOfPages()
    )
    return

  $scope.NumberOfPages = () ->
    WardsFactory.getCount((res) ->
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
    $scope.getWards($scope.filterKey)
    $scope.noPrevious = false
    return

  $scope.pageBack = ->
    $scope.filterKey.pageNumber -= 1
    $scope.noPrevious = $scope.filterKey.pageNumber == 1 ? true : false
    $scope.getWards($scope.filterKey)
    $scope.noNext = false
    return

  $scope.init()
  $scope.getWards($scope.filterKey)
  $scope.NumberOfPages()
  return
