app.factory 'CreateUserFactory',['$http', ($http) ->
  Parse.initialize "l0JxXhedCkA8D1Z2EKyfG9AMbEF0L8oDW743XI13", "Sz4w7HWy38q4hqrIJxuGVkIGSFa3V0WoqElHKoqW"

  getRoles = (callback) ->
    getQuery = new Parse.Query 'Roles'
    getQuery.find({
      success: (res) ->
        callback res
      error: (error) ->
        alert 'Error: ' + error.message
    })

  createUser = (userData, callback) ->
    Parse.User.signUp(userData.name, userData.password, { ACL: new Parse.ACL(), mobileNumber: userData.mobileNumber, email: userData.email, role: userData.role, ward: userData.ward}, {
      success: (user) ->
#        loggedInUser = user
#        alert 'user saved..'
        callback user

      error: (user, error) ->
        alert 'Error: ' + error.message
    })
    return

  sendSms = (data) ->
    $http
    .post('http://api.mVaayoo.com/mvaayooapi/MessageCompose?user=Dilip@cannybee.in:8686993306&senderID=TEST SMS&receipientno=' + data.mobile + '&msgtxt= ' + data.message + ' &state=4')
    .success((data, status, headers, config) ->
    )
    .error((status) ->
    )

  return {
    createUser: createUser
    sendSms: sendSms
    getRoles: getRoles
  }
]


app.controller 'CreateUserController', ($scope, $rootScope, CreateUserFactory, DataFactory) ->
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

  $scope.addUser = ->
    $scope.errorMessage = false
    $scope.successMessage = false
    newUser =
      name: $scope.user.name
      password: $scope.user.password
      email: $scope.user.email
      mobileNumber: $scope.user.mobileNumber
      ward: $scope.user.ward
      role: $scope.user.role

    CreateUserFactory.createUser(newUser, (res) ->
      $scope.showSuccess()
      return
    )
    $scope.showSuccess = ->
      $scope.$apply(() ->
        $scope.successMessage = true
        $scope.successText = "User created successfully.!"
        return
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
