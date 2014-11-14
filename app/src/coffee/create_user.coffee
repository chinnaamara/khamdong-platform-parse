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
        callback 'error'
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

  userInfo = {}

  return {
    createUser: signUpUser
    saveUser: saveUser
    sendSms: sendSms
    getRoles: getRoles
    userInfo: userInfo
  }

app.controller 'CreateUserController', ($scope, $rootScope, CreateUserFactory, LoginFactory, DataFactory, $location, $modal) ->
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

  $scope.addUser = (data) ->
    CreateUserFactory.userInfo = data
    $scope.errorMessage = false
    $scope.successMessage = false

    if $rootScope.adminCredentials && $scope.currentUser.role == 'Admin'
      createUser()
    else
      openPasswordModal()
    return

  $scope.$on('createUserContinue', (event, args) ->
    createUser()
  )

  createUser = () ->
    userData = CreateUserFactory.userInfo
    CreateUserFactory.createUser(userData, (res) ->
      if res != 'error'
        CreateUserFactory.saveUser(userData, (data) ->
          LoginFactory.login($rootScope.adminCredentials, (res) ->
          )
          sendMessage data, userData.password
          showSuccess userData.username
        )
      else
        showError userData.username
      return
    )


  sendMessage = (data, password) ->
    message = {
      text: "Hi " + data._serverData.username + ", you are registered as represent at Khamdong, for " + data._serverData.ward + " ward. Login with your username and pwd: " + password
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

  showError = (username) ->
    $scope.errorMessage = true
    $scope.errorText = "Try another username, User already existed with username: " + username
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

  openPasswordModal = ->
    modalInstance = $modal.open({
#      modalTemplate: '<div id="reportModalTemplate" class="modal modal-dialog modal-content" ng-transclude></div>',
      width:'custom-width',
      backdrop: 'static',
      templateUrl: 'html/admin_password.html',
      controller: 'PasswordModalController'
    })



  $scope.init()
  $scope.getWards()
  $scope.getRoles()
  return

app.controller 'PasswordModalController', ($scope, $modalInstance, $rootScope, LoginFactory) ->
  $scope.ok = (pwd) ->
    credentials = {
      username: $rootScope.userName
      password: pwd.password
    }
    LoginFactory.login(credentials, (res) ->
      if typeof res == 'string'
        $scope.$apply(() ->
          $scope.loginFail = true
          $scope.errorMessage = 'Please enter correct password.'
        )
      else
        $rootScope.adminCredentials = credentials
        $rootScope.$broadcast('createUserContinue', {text: 'from PasswordModalController'})
        $modalInstance.dismiss('cancel')
    )

  $scope.cancel = ->
    $modalInstance.dismiss('cancel')
  return
