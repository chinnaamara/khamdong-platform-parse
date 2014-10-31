app.factory 'UsersFactory', ($firebase, BASEURI, $http) ->
  getUsersRef = new Firebase BASEURI + 'superusers'
  categoriesRef = new Firebase BASEURI + 'categories'
  #  getCatgeries = $firebase categoriesRef
  usersList = $firebase getUsersRef

  pageNext = (filterKey, id, noOfRecords, cb) ->
    getRef = new Firebase BASEURI + filterKey
    getRef.startAt(null, id).limit(noOfRecords).once('value', (snapshot) ->
      cb _.values snapshot.val()
    )

  pageBack = (filterKey, id, noOfRecords, cb) ->
    getRef = new Firebase BASEURI + filterKey
    getRef.endAt(null, id).limit(noOfRecords).once('value', (snapshot) ->
      cb _.values snapshot.val()
    )

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


  addNewUser = (user) ->
    addRef = new Firebase BASEURI + 'superusers/' + user.id
    addWithCategoryRef = new Firebase BASEURI + 'categories/' + user.category + '/users/' + user.id
    addRef.child('id').set user.id
    addRef.child('name').set user.name
    addRef.child('email').set user.email
    addRef.child('mobileNumber').set user.mobileNumber
    addRef.child('category').set user.category
    addRef.child('createdDate').set user.createdDate
    addRef.child('updatedDate').set user.updatedDate

    addWithCategoryRef.child('id').set user.id
    addWithCategoryRef.child('name').set user.name
    addWithCategoryRef.child('email').set user.email
    addWithCategoryRef.child('mobileNumber').set user.mobileNumber
    addWithCategoryRef.child('category').set user.category
    addWithCategoryRef.child('createdDate').set user.createdDate
    addWithCategoryRef.child('updatedDate').set user.updatedDate
    return 'true'

  saveSentMessage = (data) ->
    addMessageRef = new Firebase BASEURI + 'sentMessages/' + data.messageId
    addMessageRef.child('id').set data.messageId
    addMessageRef.child('numbers').set data.mobileNumbers
    addMessageRef.child('messageText').set data.messageText
    addMessageRef.child('dateTime').set data.dateTime

    return 'true'

#    addRef.child(user.id).setWithPriority({
#      id: user.id
#      name: user.name
#      email: user.email
#      mobileNumber: user.mobileNumber
#      category: user.category
#      createdDate: user.createdDate
#      updatedDate: user.updatedDate
#    }, user.category)

  deleteUser = (id) ->
    deleteRef = getUsersRef.child(id)
    deleteRef.remove()
    return 'true'

  return {
    usersRef: getUsersRef
    usersList: usersList
    pageNext: pageNext
    pageBack: pageBack
    sendSms: sendSms
    addNewUser: addNewUser
    delete: deleteUser
    saveSentMessage: saveSentMessage
  }

app.controller 'UsersController', ($scope, UsersFactory, $rootScope, $window, CategoriesFactory, $firebase, BASEURI) ->
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

#  getQuery = UsersFactory.usersRef
  $scope.pageNumber = 0
  $scope.lastPageNumber = null
  recordsPerPage = 5
  bottomRecord = null
  $scope.noPrevious = true
  $scope.userslist = {}
  filterKey = 'superusers'

  getFirstPageData = ->
    getQuery = new Firebase BASEURI + filterKey
    getQuery.startAt().limit(recordsPerPage).on('value', (snapshot) ->
      $scope.userslist = _.values snapshot.val()
      $scope.loadDone = true
      $scope.loading = false
      bottomRecord = $scope.userslist[$scope.userslist.length - 1]
      if bottomRecord
        UsersFactory.pageNext(filterKey, bottomRecord.id, recordsPerPage + 1, (res) ->
          if res
            $scope.noNext = res.length <= 1
        )
      else
        $scope.noNext = true
      return
    )
    return

  getFirstPageData()


  $scope.pageNext = ->
    $scope.pageNumber++
    $scope.noPrevious = false
    bottomRecord = $scope.userslist[$scope.userslist.length - 1]
    UsersFactory.pageNext(filterKey, bottomRecord.id, recordsPerPage + 1, (res) ->
      if res
        res.shift()
        $scope.userslist = res
        bottomRecord = $scope.userslist[$scope.userslist.length - 1]
    )
    UsersFactory.pageNext(filterKey, bottomRecord.id, recordsPerPage + 1, (res) ->
      if res
        $scope.noNext = res.length <= 1
    )

  $scope.pageBack = ->
    $scope.pageNumber--
    $scope.noNext = false
    topRecord = $scope.userslist[0]
    UsersFactory.pageBack(filterKey, topRecord.id, recordsPerPage + 1, (res) ->
      if res
        res.pop()
        $scope.userslist = res
        $scope.noPrevious = $scope.pageNumber is 0
    )

  $scope.cantSendMessage = true
  $scope.allUsersClicked = () ->
    newValue = ! $scope.allUsersMet()
    _.forEach($scope.userslist, (user) ->
      user.done = newValue
      return
    )
    return

  $scope.allUsersMet = ->
    usersMet = _.reduce($scope.userslist, (count, user) ->
      return count + user.done ? 1 : 0
    , 0)
    $scope.cantSendMessage = $scope.getUsers().length == 0
    return (usersMet == $scope.userslist.length)

  $scope.selectedUsers = []
  $scope.isUser = ->
    $scope.selectedUsers = $scope.getUsers()
    $scope.str = 'to '
    _.forEach($scope.selectedUsers, (user) ->
      $scope.str += user + ', '
    )
    console.log $scope.str.substring(0, $scope.str.length - 2)

  $scope.getUsers = ->
    users = []
    _.forEach($scope.userslist, (user) ->
      if user.done
        users.push Number user.mobileNumber
    )
    return users

  $scope.sendSms = ->
    _.forEach($scope.selectedUsers, (user) ->
      UsersFactory.sendSms($scope.messageText, user)
    )
    newMessage =
      messageId: new Date().getTime()
      mobileNumbers: $scope.str.substring(0, $scope.str.length - 2)
      messageText: $scope.messageText
      dateTime: new Date().toLocaleString()

    $scope.$watch(UsersFactory.saveSentMessage(newMessage), (res) ->
      if res
        console.log 'message saved in sent items..'
    )

    $scope.messageText = ''
    #    $scope.successMessage = true
    return

  #  $scope.reset = ->
  #    $scope.messageText = ''
  ##    $scope.successMessage = false
  #    return

  $scope.isNewUser = ->
    $scope.modelTitle = 'Add New User'
    $scope.buttonText = 'Add'
    $scope.newUserName = ""
    $scope.mobileNumber = ""
    $scope.email = ""
    $scope.successMessage = false
    $scope.category = ""

  CategoriesFactory.getCategories(100, (res) ->
    $scope.categories = res
  )

  userId = (category) ->
    date = new Date()
    refID = date.getTime()
    str1 = category.substring(0, 2).toUpperCase()
    refID + str1

  $scope.addNewUser = ->
    if $scope.buttonText == 'Add'
      $scope.statusText = 'User Created Successfully.!'
      newUser =
        id: userId $scope.category
        category: $scope.category
        name: $scope.newUserName
        mobileNumber: $scope.mobileNumber
        email: $scope.email
        createdDate: new Date().toLocaleString()
        updatedDate: new Date().toLocaleString()
    else
      $scope.statusText = 'User Updated Successfully.!'
      newUser =
        id: $scope.userById.id
        category: $scope.category
        name: $scope.newUserName
        mobileNumber: $scope.mobileNumber
        email: $scope.email
        createdDate: new Date().toLocaleString()
        updatedDate: new Date().toLocaleString()
    $scope.$watch(UsersFactory.addNewUser(newUser), (res) ->
      if res
        $scope.successMessage = true
    )

  $scope.userById = {}
  $scope.editUser = (user) ->
    $scope.userById.id = user.id
    $scope.modelTitle = 'Edit User'
    $scope.buttonText = 'Update'
    $scope.newUserName = user.name
    $scope.mobileNumber = user.mobileNumber
    $scope.email = user.email
    $scope.successMessage = false
    $scope.category = user.category

  $scope.getCategoryUsers = ->
    if $scope.selectCategory
      filterKey = 'categories/' + $scope.selectCategory + '/users'
      getFirstPageData()
    else
      filterKey = 'superusers'
      getFirstPageData()
    return

  $scope.deleteUser = (user) ->
    $scope.$watch(UsersFactory.delete(user.id), (res) ->
      if res
        console.log 'deleted success'
      else
        console.log 'not deleted'
    )

app.directive('ngConfirmClick',[ () ->
  return {
  priority: -1
  restrict: 'A'
  link: (scope, element, attrs) ->
    element.on('click', (e) ->
      message = attrs.ngConfirmClick
      if(message && !confirm(message))
        e.originalEvent.stopImmediatePropagation()
        e.preventDefault()
      return
    )
    return
  }
])


