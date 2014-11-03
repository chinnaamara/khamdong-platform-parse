app.factory 'AdminUsersFactory', ($http) ->
  Parse.initialize "l0JxXhedCkA8D1Z2EKyfG9AMbEF0L8oDW743XI13", "Sz4w7HWy38q4hqrIJxuGVkIGSFa3V0WoqElHKoqW"
  getUsers = (filterKey, callback) ->
    getQuery = new Parse.Query 'UserInfo'
    getQuery.descending "createdAt"
    getQuery.equalTo filterKey.columnName, filterKey.keyValue
    getQuery.limit filterKey.pageLimit
    getQuery.skip(filterKey.pageLimit * (filterKey.pageNumber - 1))
    getQuery.find({
      success: (res) ->
        callback res
      error: (error) ->
        alert 'Error: ' + error.message
    })
    return

  getCount = (callback) ->
    getQuery = new Parse.Query 'UserInfo'
    getQuery.count({ success: (result) -> callback result })
    return

  transferUser = (userData, callback) ->
    transferQuery = new Parse.Query 'UserInfo'
    transferQuery.equalTo 'objectId', userData.id
    transferQuery.first({
      success: (object) ->
        object.save(null, {
          success: (object) ->
            object.set 'ward', userData.ward
            object.set 'role', userData.role
            object.set 'mobileNumber', userData.mobileNumber
            object.save()
            callback object
        })
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
    return

  userById = {}

  return {
    getUsers: getUsers
    getCount: getCount
    sendSms: sendSms
    userById: userById
    transferUser: transferUser
  }

app.controller 'AdminUsersController', ($scope, AdminUsersFactory, $rootScope, DataFactory, $location) ->

  $scope.filterKey = {
    pageNumber: 1
    pageLimit: 6
    columnName: undefined
    keyValue: undefined
  }
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

  $scope.getWards = ->
    DataFactory.getWards((res) ->
      $scope.$apply(() ->
        $scope.wards = res
      )
    )
    return

  $scope.getUsers = (filterKey) ->
    AdminUsersFactory.getUsers(filterKey, (res) ->
      $scope.$apply(() ->
        $scope.users = res
      )
    )
    return

  $scope.NumberOfPages = () ->
    AdminUsersFactory.getCount((res) ->
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
    $scope.getUsers($scope.filterKey)
    $scope.noPrevious = false
    return

  $scope.pageBack = ->
    $scope.filterKey.pageNumber -= 1
    $scope.noPrevious = $scope.filterKey.pageNumber == 1 ? true : false
    $scope.getUsers($scope.filterKey)
    $scope.noNext = false
    return

  $scope.manageUser = (user) ->
    AdminUsersFactory.userById = user
    $location.path '/admin/users/manage'
    return

  $scope.filterUsers = ->
    $scope.searchKey = ''
    $scope.filterKey.columnName = 'ward'
    $scope.filterKey.keyValue = $scope.selectedWard
    $scope.filterKey.pageNumber = 1
    $scope.NumberOfPages()
    $scope.getUsers($scope.filterKey)
    return

  $scope.searchResult = ->
    $scope.filterKey.pageNumber = 1
    if $scope.searchKey
      $scope.filterKey.columnName = 'mobileNumber'
      $scope.filterKey.keyValue = $scope.searchKey
    else
      $scope.filterKey.columnName = undefined
      $scope.filterKey.queryValue = undefined
    $scope.NumberOfPages($scope.filterKey)
    $scope.getUsers($scope.filterKey)
    return

  $scope.init()
  $scope.getWards()
  $scope.NumberOfPages()
  $scope.getUsers($scope.filterKey)
  return
