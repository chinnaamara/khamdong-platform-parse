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

  #    wards.save({wardName: wardName, ACL: new Parse.ACL()}).then((object) ->
  #      alert "ward saved"
  #    )  name: userData.name


  getWards = (callback) ->
    getQuery = new Parse.Query Wards
    getQuery.find({
      success: (result) ->
        callback result
      error: (error) ->
        alert 'Error: ' + error.message
    })
    return

  return {
    getWards: getWards
    createWard: createWard
  }

app.controller 'WardsController', ($scope, $rootScope, WardsFactory, $window) ->
#  $scope.init = ->
#    session = localStorage.getItem('firebaseSession')
#    if ! session
#      $window.location = '#/error'
#    else
#      $rootScope.userName = localStorage.getItem('name').toUpperCase()
#      role = localStorage.getItem('role')
#      $rootScope.administrator = role == 'Admin'
#      $rootScope.superUser = role == 'SuperUser'

#  $scope.init()

  $scope.getWards = ->
    WardsFactory.getWards((res) ->
#      console.log res[0]._serverData.name
      $scope.$apply(() ->
        $scope.wards = res
        console.log $scope.wards
      )
    )
  $scope.getWards()

  $scope.btnAdd = ->
    $scope.modelTitle = 'Add New Ward'
    $scope.wardName = ''
    $scope.buttonText = 'Add'

  $scope.addNewWard = ->
    WardsFactory.createWard($scope.wardName, (res) ->
      if res
        $scope.getWards()
      else
        console.log 'ward not added'
    )

  $scope.wardName = ''
  $scope.wardById = {}
  $scope.editWard = (ward) ->
    $scope.modelTitle = 'Edit Ward'
    $scope.buttonText = 'Update'
    $scope.wardById.wardId = ward.id
    $scope.wardName = ward._serverData.name
    $scope.wardById.createdDate = ward.createdDate
