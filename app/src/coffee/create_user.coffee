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


app.controller 'CreateUserController', ($scope, CreateUserFactory, WardsFactory) ->

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
      console.log res
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

#  $scope.signUp = (data) ->
#    smsData = {
#      mobile: $scope.user.mobileNumber
#      message: "Hi " + $scope.user.name + ", you are registered as represent at Khamdong, for " + $scope.user.ward + " ward. Login with email: " + $scope.user.email  + ", pwd: " + $scope.user.password
#    }
#    auth.$createUser(data.email, data.password).then((user) ->
##      console.log 'User: ' , user
#      $scope.$watch(CreateUserFactory.sendSms(smsData), (status) ->
#        if status
#          console.log "sms sent to " + smsData.mobile
#      )
#      $scope.successMessage = true
#      $scope.successText = "User created successfully.!"
#      return
#    , (error) ->
#      console.log 'error: ' + error.code
#      removeUser data.id
#      $scope.errorMessage = true
#      $scope.errorText = "Email already used.! Try another Email."
#      return
#    )
#    return

  $scope.getRoles = ->
    CreateUserFactory.getRoles((res) ->
      $scope.$apply(() ->
        $scope.roles = res
      )
    )
  $scope.getWards = ->
    WardsFactory.getWards((res) ->
#      console.log res[0]._serverData.name
      $scope.$apply(() ->
        $scope.wards = res
#        console.log $scope.wards
      )
    )
  $scope.getWards()
  $scope.getRoles()

  return
