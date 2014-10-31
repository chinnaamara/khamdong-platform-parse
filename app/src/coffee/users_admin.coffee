app.factory 'AdminUsersFactory', ($http) ->
  Parse.initialize "l0JxXhedCkA8D1Z2EKyfG9AMbEF0L8oDW743XI13", "Sz4w7HWy38q4hqrIJxuGVkIGSFa3V0WoqElHKoqW"
#  Wards = Parse.Object.extend 'Wards'
  getUsers = (callback) ->
    getQuery = new Parse.Query 'User'
    getQuery.find({
      success: (res) ->
        console.log res
        callback res
      error: (error) ->
        alert 'Error: ' + error.message
    })
    return

  sendSms = (message, mobile) ->
    $http
    .post('http://api.mVaayoo.com/mvaayooapi/MessageCompose?user=Dilip@cannybee.in:8686993306&senderID=TEST SMS&receipientno=' + mobile + '&msgtxt= ' + message + ' &state=4')
    .success((data, status, headers, config) ->
#      alert "Message sent success to your mobile number"
    )
    .error((status) ->
#      alert status.responseText
#      alert "Message sent to your mobile number"
    )

  userById = {}

  return {
    getUsers: getUsers
    sendSms: sendSms
    userById: userById
  }

app.controller 'AdminUsersController', ($scope, AdminUsersFactory, $rootScope, DataFactory) ->
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

  $scope.getUsers = ->
    AdminUsersFactory.getUsers((res) ->
      $scope.$apply(() ->
        $scope.users = res
        console.log $scope.users
      )
    )
    return

  $scope.manageUser = (user) ->
    AdminUsersFactory.userById = user
    $window.location = '#/admin/users/manage'
    return

  $scope.init()
  $scope.getUsers()
