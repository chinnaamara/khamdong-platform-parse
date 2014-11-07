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

  getUserInfo = (username, callback) ->
    getQuery = new Parse.Query 'UserInfo'
    getQuery.equalTo 'username', username
    getQuery.find({
      success: (res) ->
        callback res
      error: (error) ->
        alert 'Error: ' + error.message
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
    getUserInfo: getUserInfo
#    getUser: getUser
  }

app.controller 'LoginController', ($scope, $rootScope, LoginFactory, $location) ->
  $scope.signIn = (userData) ->
    $scope.sighning = true
    $scope.loginFail = false
    $scope.errorMessage = 'Login Failed!'
    $rootScope.adminCredentials = userData

    LoginFactory.login(userData, (res) ->
      if typeof res == 'string'
        $scope.$apply(() ->
          $scope.sighning = false
          $scope.loginFail = true
          $scope.errorMessage = res
        )
      else
        LoginFactory.getUserInfo(res._serverData.username, (info) ->
          localStorage.setItem('username', info[0]._serverData.username)
          localStorage.setItem('ward', info[0]._serverData.ward)
          localStorage.setItem('role', info[0]._serverData.role)
          localStorage.setItem('mobile', info[0]._serverData.mobileNumber)
          $scope.$apply(() ->
            $location.path '/user/grievances'
          )
        )
        return
    )
    return

  $scope.logout = ->
    $rootScope.userName = null
    $rootScope.administrator = null
    $rootScope.superUser = null
    LoginFactory.logOut()
    localStorage.clear()
    $location.path '/logout'
    return
