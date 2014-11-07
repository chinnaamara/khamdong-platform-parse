app.controller 'ManageUserController', ($scope, AdminUsersFactory, $rootScope, DataFactory) ->
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

  $scope.userById = AdminUsersFactory.userById

  $scope.getWards = ->
    DataFactory.getWards((res) ->
      $scope.$apply(() ->
        $scope.wards = res
      )
    )
    return

  $scope.getRoles = ->
    DataFactory.getRoles((res) ->
      $scope.$apply(() ->
        $scope.roles = res
      )
    )
    return

  $scope.btnTransfer = ->
    $scope.successMessage = false
    $scope.transferUserName = $scope.userById._serverData.username
    $scope.transferWardName = $scope.userById._serverData.ward
    return

  $scope.transferUser = ->
    updateRec =
      id: $scope.userById.id
      username: $scope.userById._serverData.username
      mobileNumber: $scope.userById._serverData.mobileNumber
      ward: $scope.userById._serverData.ward
      role: $scope.userById._serverData.role
    AdminUsersFactory.transferUser(updateRec, (res) ->
      $scope.$apply(() ->
        $scope.successMessage = true
        $scope.successText = "User Transferred successfully!"
      )
      sendMessage()
    )
    return

    sendMessage = ->
      messageData = {
        mobileNumber: $scope.userById._serverData.mobileNumber
        text: 'Hi ' + $scope.userById._serverData.username + 'you are transfered to ' + $scope.userById._serverData.ward + 'ward, You can login with your current username and password.'
      }
      AdminUsersFactory.sendSms(messageData, (res) ->
        console.log res
      )

  $scope.init()
  $scope.getWards()
  $scope.getRoles()
  return
