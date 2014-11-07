app.factory 'CreateUserFactory', ($http) ->
  Parse.initialize "l0JxXhedCkA8D1Z2EKyfG9AMbEF0L8oDW743XI13", "Sz4w7HWy38q4hqrIJxuGVkIGSFa3V0WoqElHKoqW"

  getRoles = (callback) ->
    getQuery = new Parse.Query 'Roles'
    getQuery.find({
      success: (res) ->
        callback res
      error: (error) ->
        alert 'Error: ' + error.message
    })
    return

  signUpUser = (userData, callback) ->
    Parse.User.signUp(userData.username, userData.password, { ACL: new Parse.ACL(), email: userData.email}, {
      success: (user) ->
#        loggedInUser = user
#        alert 'user saved..'
        callback user

      error: (user, error) ->
        alert 'Error: ' + error.message
    })
    return

  saveUser = (userData, callback) ->
    UserInfo = Parse.Object.extend 'UserInfo'
    newUser = new UserInfo()
    newUser.save({username: userData.username, ward: userData.ward, role: userData.role, mobileNumber: userData.mobileNumber}, {
      success: (object) ->
        callback(object)
      error: (error) ->
        alert("Error: " + error.message)
    })
    return

  sendSms = (data, callback) ->
    $http
    .post('http://api.mVaayoo.com/mvaayooapi/MessageCompose?user=Dilip@cannybee.in:8686993306&senderID=TEST SMS&receipientno=' + data.mobileNumber + '&msgtxt= ' + data.text + ' &state=4')
    .success((data, status, headers, config) ->
      callback status.message
    )
    .error((status) ->
      callback status.message
    )
    return

  return {
    createUser: signUpUser
    saveUser: saveUser
    sendSms: sendSms
    getRoles: getRoles
  }

app.controller 'CreateUserController', ($scope, $rootScope, CreateUserFactory, LoginFactory, DataFactory, $location) ->
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

  $scope.addUser = ->
    $scope.errorMessage = false
    $scope.successMessage = false
    newUser =
      username: $scope.user.name
      password: $scope.user.password
      email: $scope.user.email
      mobileNumber: $scope.user.mobileNumber
      ward: $scope.user.ward
      role: $scope.user.role

    if $scope.currentUser.role == 'Admin'
      CreateUserFactory.createUser(newUser, (res) ->
        CreateUserFactory.saveUser(newUser, (data) ->
          LoginFactory.login($rootScope.adminCredentials, (res) ->
#            showSuccess(data._serverData.username)
          )
          sendMessage data
          showSuccess data._serverData.username
        )
        return
      )
    else
      alert 'You are not authorized!'
    return

  sendMessage = (data) ->
    message = {
      text: "Hi " + data._serverData.username + ", you are registered as represent at Khamdong, for " + data._serverData.ward + " ward. Login with your username and pwd: " + $scope.user.password
      mobileNumber: data._serverData.mobileNumber
    }
    CreateUserFactory.sendSms(message, (res) ->
      console.log res
    )
    return

  showSuccess = (username) ->
    $scope.$apply(() ->
      $scope.successMessage = true
      $scope.successText = "User created successfully with username: " + username
    )
    return

  $scope.getRoles = ->
    DataFactory.getRoles((res) ->
      $scope.$apply(() ->
        $scope.roles = res
      )
    )
    return

  $scope.getWards = ->
    DataFactory.getWards((res) ->
      $scope.$apply(() ->
        $scope.wards = res
      )
    )
    return

  $scope.init()
  $scope.getWards()
  $scope.getRoles()
  return
