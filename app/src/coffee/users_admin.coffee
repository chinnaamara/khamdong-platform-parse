app.factory 'AdminUsersFactory', ($firebase, BASEURI, $http) ->
  getUsersRef = new Firebase BASEURI + 'users'
  usersList = $firebase getUsersRef

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
    usersRef: getUsersRef
    usersList: usersList
    sendSms: sendSms
    userById: userById
  }

app.controller 'AdminUsersController', ($scope, AdminUsersFactory, $rootScope, $window, DataFactory, $filter, ngTableParams) ->
  $scope.init = ->
    session = localStorage.getItem('firebaseSession')
    if ! session
      $window.location = '#/error'
    else
      $rootScope.userName = localStorage.getItem('name').toUpperCase()
      role = localStorage.getItem('role')
      $rootScope.administrator = role == 'Admin'
      $rootScope.superUser = role == 'SuperUser'

  $scope.init()

  $scope.loadDone = false
  $scope.loading = true
  getQuery = AdminUsersFactory.usersRef

  getUsersList = ->
    $scope.adminUsersTable = new ngTableParams(
      page: 1
      count: 7
      sorting:
        role:'asc'
    ,
      counts: []
      total: 0
      getData: ($defer, params) ->
        filteredData = $filter("filter")($scope.userslist, $scope.filter)
        orderedData = (if params.sorting() then $filter("orderBy")(filteredData, params.orderBy()) else filteredData)
        params.total orderedData.length
        $defer.resolve orderedData.slice((params.page() - 1) * params.count(), params.page() * params.count())
        return
      $scope: $scope
    )
    return

  getQuery.on('value', (snapshot) ->
    $scope.userslist = _.values snapshot.val()
    getUsersList()
    $scope.loadDone = true
    $scope.loading = false
  )
  $scope.searchFilter = ->
    $scope.$watch "filter.$", ->
      $scope.adminUsersTable.reload()
      return
    return

  $scope.manageUser = (user) ->
    AdminUsersFactory.userById = user
    $window.location = '#/admin/users/manage'
