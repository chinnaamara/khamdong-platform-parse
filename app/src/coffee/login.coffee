app.factory 'LoginFactory', () ->
  Parse.initialize "l0JxXhedCkA8D1Z2EKyfG9AMbEF0L8oDW743XI13", "Sz4w7HWy38q4hqrIJxuGVkIGSFa3V0WoqElHKoqW"

  loggedInUser = ''
  login = (data, callback) ->
    Parse.User.logIn(data.username, data.password, {
      success: (user) ->
        loggedInUser = user
        callback user
      error: (user, error) ->
#        alert "Error: " + error.message
        callback error.message
    })
    return

  logOut = ->
    Parse.User.logOut();
    return

#  getUser = ->
#    if loggedInUser
#      return loggedInUser
#    return

  return {
    login: login
    logOut: logOut
#    getUser: getUser
  }

app.controller 'LoginController', ($scope, $rootScope, LoginFactory, $location) ->
  $scope.signIn = (userData) ->
    $scope.sighning = true
    $scope.loginFail = false
    $scope.errorMessage = 'Login Failed!'

    LoginFactory.login(userData, (res) ->
      if typeof res == 'string'
        $scope.$apply(() ->
          $scope.sighning = false
          $scope.loginFail = true
          $scope.errorMessage = res
        )
      else
        $scope.$apply(() ->
          $location.path '/user/grievances'
        )
        return
    )
    return

  $scope.logout = ->
    $rootScope.userName = null
    $rootScope.administrator = null
    $rootScope.superUser = null
    $location.path '/logout'
    LoginFactory.logOut()
    return
