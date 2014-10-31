app.factory 'MembersFactory', ($http) ->
  Parse.initialize "l0JxXhedCkA8D1Z2EKyfG9AMbEF0L8oDW743XI13", "Sz4w7HWy38q4hqrIJxuGVkIGSFa3V0WoqElHKoqW"

  Members = Parse.Object.extend 'Members'
  createMember = (member, callback) ->
    members = new Members
    members.save({name: member.name, mobileNumber: member.mobileNumber, email: member.email, category: member.category}, {
      success: (object) ->
        callback object
      error: (error) ->
        alert("Error: " + error.message)
    })
    return

  readMembers = (filterKey, callback) ->
    getQuery = new Parse.Query Members
    getQuery.descending "createdAt"
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
    getQuery = new Parse.Query Members
    getQuery.count({ success: (result) -> callback result })
    return

  updateMember = (data, callback) ->
    updateQuery = new Parse.Query Members
    updateQuery.equalTo 'objectId', data.id
    updateQuery.first({
      success: (object) ->
        object.save(null, {
          success: (object) ->
            object.set 'name', data.name
            object.set 'mobileNumber', data.mobileNumber
            object.set 'email', data.email
            object.set 'category', data.category
            object.save()
            callback object
        })
    })
    return

  deleteMember = (memberId, callback) ->
    deleteQuery = new Parse.Query Members
    deleteQuery.equalTo 'objectId', memberId
    deleteQuery.each((object) ->
      object.destroy({
        success: (object) ->
          callback object
      })
    )
    return

  sendSms = (message, mobile, callback) ->
    $http
    .post('http://api.mVaayoo.com/mvaayooapi/MessageCompose?user=Dilip@cannybee.in:8686993306&senderID=TEST SMS&receipientno=' + mobile + '&msgtxt= ' + message + ' &state=4')
    .success((data, status, headers, config) ->
      callback status
    )
    .error((status) ->
      callback status.responseText
#      alert status.responseText
    )

  saveSentMessage = (data, callback) ->
    Messages = Parse.Object.extend 'SentMessages'
    message = new Messages()
    message.save({mobileNumber: data.mobileNumber, text: data.text}, {
      success: (object) ->
        callback object
      error: (error) ->
        alert("Error: " + error.message)
    })
    return

  return {
    addNewMember: createMember
    getMembers: readMembers
    updateMember: updateMember
    deleteMember: deleteMember
    getCount: getCount
    sendSms: sendSms
    saveSentMessage: saveSentMessage
  }

app.controller 'MembersController', ($scope, MembersFactory, $rootScope, $location, DataFactory) ->
  $scope.filterKey = {
    pageNumber: 1
    pageLimit: 6
  }

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

  $scope.getCategories = () ->
    DataFactory.getCategories((res) ->
      $scope.$apply(() ->
        $scope.categories = res
      )
    )

  $scope.getMembers = (filterKey) ->
    MembersFactory.getMembers(filterKey, (res) ->
      $scope.$apply(() ->
        $scope.members = res
      )
    )
    return

  $scope.btnAdd = ->
    $scope.modelTitle = 'Add New Member'
    $scope.name = ''
    $scope.mobileNumber = ''
    $scope.email = ''
    $scope.category = ''
    $scope.buttonText = 'Add'
    return

  $scope.btnEdit = (member) ->
    $scope.modelTitle = member.id
    $scope.buttonText = 'Update'
    $scope.memberId = member.id
    $scope.name = member._serverData.name
    $scope.mobileNumber = member._serverData.mobileNumber
    $scope.email = member._serverData.email
    $scope.category = member._serverData.category
    return

  $scope.addEditClick = ->
    data =
      name: $scope.name
      mobileNumber: $scope.mobileNumber
      email: $scope.email
      category: $scope.category
    console.log data
    if $scope.buttonText == 'Add'
      addNewMember(data)
    else
      data.id = $scope.memberId
      updateMember(data)
    return

  addNewMember = (member) ->
    MembersFactory.addNewMember(member, (res) ->
      if res
        $scope.getMembers($scope.filterKey)
        $scope.NumberOfPages()
      else
        alert 'Member not added.'
    )
    return

  updateMember = (member) ->
    MembersFactory.updateMember(member, (res) ->
      if res
        $scope.getMembers($scope.filterKey)
        $scope.NumberOfPages()
      else
        alert 'Member not updated.'
    )
    return

  $scope.deleteConformation = (member) ->
    $scope.deleteMemberName = member._serverData.name
    $scope.deleteMemberId = member.id
    return

  $scope.deleteMember = ->
    MembersFactory.deleteMember($scope.deleteMemberId, (res) ->
      $scope.getMembers($scope.filterKey)
      $scope.NumberOfPages()
    )
    return

  $scope.NumberOfPages = () ->
    MembersFactory.getCount((res) ->
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
    $scope.getMembers($scope.filterKey)
    $scope.noPrevious = false
    return

  $scope.pageBack = ->
    $scope.filterKey.pageNumber -= 1
    $scope.noPrevious = $scope.filterKey.pageNumber == 1 ? true : false
    $scope.getMembers($scope.filterKey)
    $scope.noNext = false
    return

  $scope.init()
  $scope.getCategories()
  $scope.getMembers($scope.filterKey)
  $scope.NumberOfPages()

  $scope.cantSendMessage = true
  $scope.allMembersClicked = () ->
    newValue = ! $scope.allMembersMet()
    _.forEach($scope.members, (member) ->
      member.done = newValue
      return
    )
    return

  $scope.allMembersMet = ->
    membersMet = _.reduce($scope.members, (count, member) ->
      return count + member.done ? 1 : 0
    , 0)
    $scope.cantSendMessage = $scope.pickedMembers().length == 0
    return (membersMet == $scope.members.length)

  $scope.selectedMembers = []
  $scope.isMember = ->
    $scope.selectedMembers = $scope.pickedMembers()
    $scope.str = 'to '
    _.forEach($scope.selectedMembers, (member) ->
      $scope.str += member + ', '
    )
    console.log $scope.str.substring(0, $scope.str.length - 2)

  $scope.pickedMembers = ->
    members = []
    _.forEach($scope.members, (member) ->
      if member.done
        members.push Number member.mobileNumber
    )
    return members

  $scope.sendSms = ->
    _.forEach($scope.selectedMembers, (member) ->
      MembersFactory.sendSms($scope.messageText, member, (res) ->
        console.log ''
      )
    )
    newMessage =
      mobileNumber: $scope.str.substring(0, $scope.str.length - 2)
      messageText: $scope.messageText

    MembersFactory.saveSentMessage(newMessage, (res) ->
      if res
        console.log 'message saved in sent items..'
    )

    $scope.messageText = ''
    #    $scope.successMessage = true
    return

    $scope.reset = ->
      $scope.messageText = ''
  #    $scope.successMessage = false
      return

  $scope.getCategoryMembers = ->
    if $scope.selectCategory
      $scope.filterKey = 'categories/' + $scope.selectCategory + '/users'
      getFirstPageData()
    else
      $scope.filterKey = 'superusers'
      getFirstPageData()
    return
