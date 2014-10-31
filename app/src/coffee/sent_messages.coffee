app.factory 'MessagesFactory', ($firebase, BASEURI) ->

  messagesRef = new Firebase BASEURI + 'sentMessages/'
  messages = $firebase messagesRef

  getMessages = (count, callback) ->
    messagesRef.startAt().limit(count).on('value', (res) ->
      callback _.values res.val()
    )

  deleteMessage = (id) ->
    deleteRef = messagesRef.child(id)
    deleteRef.remove()
    return 'true'

  return {
    messages: messages
    getMessages: getMessages
    messagesRef: messagesRef
    delete: deleteMessage
  }

app.controller 'MessagesController', ($scope, $rootScope, MessagesFactory, $window) ->
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

  $scope.messages = MessagesFactory.messages

  $scope.deleteMessage = (msg) ->
    $scope.$watch(MessagesFactory.delete(msg.id), (res) ->
      if res
        console.log 'deleted success'
      else
        console.log 'not deleted'
    )
