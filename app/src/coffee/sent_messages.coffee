app.factory 'MessagesFactory', () ->
  Parse.initialize "l0JxXhedCkA8D1Z2EKyfG9AMbEF0L8oDW743XI13", "Sz4w7HWy38q4hqrIJxuGVkIGSFa3V0WoqElHKoqW"

  getMessages = (filterKey, callback) ->
    getQuery = new Parse.Query 'SentMessages'
    getQuery.descending "createdAt"
    getQuery.equalTo filterKey.columnName, filterKey.keyValue
    getQuery.limit filterKey.pageLimit
    getQuery.skip(filterKey.pageLimit * (filterKey.pageNumber - 1))
    getQuery.find({
      success: (result) ->
        callback result
      error: (error) ->
        alert 'Error: ' + error.message
    })
    return

  getCount = (callback) ->
    getQuery = new Parse.Query 'SentMessages'
    getQuery.count({ success: (result) -> callback result })
    return

  deleteMessage = (messageId, callback) ->
    deleteQuery = new Parse.Query 'SentMessages'
    deleteQuery.equalTo 'objectId', messageId
    deleteQuery.each((object) ->
      object.destroy({
        success: (object) ->
          callback object
      })
    )
    return

  return {
    getMessages: getMessages
    getCount: getCount
    deleteMessage: deleteMessage
  }

app.controller 'MessagesController', ($scope, $rootScope, MessagesFactory, $location) ->
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

  $scope.getMessages = (filterKey) ->
    MessagesFactory.getMessages(filterKey, (res) ->
      $scope.$apply(() ->
        $scope.messages = res
      )
    )

  $scope.deleteConformation = (message) ->
    if $scope.currentUser.role == 'Super User'
      $scope.deleteMessageId = message.id
    else
      alert 'You are not authorized!'
    return

  $scope.deleteMessage = ->
    if $scope.currentUser.role == 'Super User'
      MessagesFactory.deleteMessage($scope.deleteMessageId, (res) ->
        $scope.getMessages($scope.filterKey)
        $scope.NumberOfPages()
      )
    else
      alert 'You are not authorized!'
    return

  $scope.NumberOfPages = () ->
    MessagesFactory.getCount((res) ->
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
    $scope.getMessages($scope.filterKey)
    $scope.noPrevious = false
    return

  $scope.pageBack = ->
    $scope.filterKey.pageNumber -= 1
    $scope.noPrevious = $scope.filterKey.pageNumber == 1 ? true : false
    $scope.getMessages($scope.filterKey)
    $scope.noNext = false
    return

  $scope.searchResult = (searchKey) ->
    console.log searchKey
    if $scope.currentUser.role == 'Super User'
      if searchKey
        $scope.filterKey.columnName = 'mobileNumber'
        $scope.filterKey.keyValue = searchKey
      else
        $scope.filterKey.columnName = undefined
        $scope.filterKey.keyValue = undefined
      $scope.getMessages($scope.filterKey)
      $scope.NumberOfPages()
    else
      alert 'You are not authorized!'
    return

  $scope.init()
  $scope.getMessages($scope.filterKey)
  $scope.NumberOfPages()
  return
