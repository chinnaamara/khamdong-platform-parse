app.factory 'DetailsFactory', ($http) ->
  Parse.initialize "l0JxXhedCkA8D1Z2EKyfG9AMbEF0L8oDW743XI13", "Sz4w7HWy38q4hqrIJxuGVkIGSFa3V0WoqElHKoqW"
  grievanceById = {}
  Grievance = Parse.Object.extend 'Grievances'
  submitResponse = (data, callback) ->
    updateQuery = new Parse.Query Grievance
    updateQuery.equalTo 'objectId', data.id
    updateQuery.first({
      success: (object) ->
        object.save(null, {
          success: (object) ->
            object.set 'department', data.department
            object.set 'grievanceType', data.grievanceType
            object.set 'scheme', data.scheme
            object.set 'requirement', data.requirement
            object.set 'respondedDate', data.respondedDate
            object.set 'message', data.message
            object.set 'status', data.status
            object.save()
            callback object
        })
    })
    return

  sendSms = (data, callback) ->
    $http
    .post('http://api.mVaayoo.com/mvaayooapi/MessageCompose?user=Dilip@cannybee.in:8686993306&senderID=TEST SMS&receipientno=' + data.mobile + '&msgtxt= ' + data.message + ' &state=4')
    .success((data, status, headers, config) ->
#      alert 'success'
      callback data
    )
    .error((status) ->
#      alert status.responseText
      callback status
    )

  return {
    retrieveGrievance: grievanceById
    submitResponse: submitResponse
    sendSms: sendSms
  }

app.controller 'DetailsController', ($scope, DetailsFactory, $rootScope, DataFactory, $location) ->
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

  $scope.getData = ->
    DataFactory.getGrievanceTypes((res) ->
      $scope.$apply(() ->
        $scope.grievanceTypes = res
      )
    )
    DataFactory.getDepartments((res) ->
      $scope.$apply(() ->
        $scope.departments = res
      )
    )
    return

  $scope.getSchemes = ->
    $scope.grievance.department = $scope.grievance._serverData.department
    DataFactory.getSchemes($scope.grievance.department, (res) ->
      $scope.$apply(() ->
        $scope.schemes = res
      )
    )
    return

  $scope.getAge = ->
    currentYear = new Date().getFullYear()
    yearOfBirth = new Date($scope.grievance._serverData.dob).getFullYear()
    $scope.age = currentYear - yearOfBirth
    return

  $scope.newValue = (value) ->
    $scope.responce = false
    if value == 'Approve'
      $scope.accept = false
      $scope.reject = true
      $scope.statusMessage = "Approved"
      $scope.message = "Your grievance is approved."
      $scope.responceMessage = "Grievance Approved!"
      $scope.smsText = " is approved, please get more details from GPU."
    else if value == 'Reject'
      $scope.accept = true
      $scope.reject = false
      $scope.statusMessage = "Rejected"
      $scope.message = "Your grievance is rejected due to"
      $scope.responceMessage = "Grievance Rejected!"
      $scope.smsText = " is rejected, please get more details from GPU."
    return

  $scope.submit = ->
#    smsData = {
#      mobile: $scope.grievance.phoneNumber
#      message: "Hi " + $scope.grievance.name + ", your grievance request with reference number " + $scope.grievance.referenceNum + $scope.smsText
#    }

    resMessage = {
      id: $scope.grievance.id
      grievanceType: $scope.grievance._serverData.grievanceType
      department: $scope.grievance._serverData.department
      scheme: $scope.grievance._serverData.scheme
      requirement: $scope.grievance._serverData.requirement
      respondedDate: new Date().toLocaleString()
      status: $scope.statusMessage
      message: $scope.message
    }
    DetailsFactory.submitResponse(resMessage, (res) ->
      if res
        $scope.$apply(() ->
          $scope.responce = true
        )
#        DetailsFactory.sendSms(smsData, (status) ->
#          if status
#            console.log "sms sent to " + smsData.mobile
#        )
    )
    return

  $scope.grievance = DetailsFactory.retrieveGrievance

  $scope.statusMessage = " "
  $scope.accept = true
  $scope.reject = true
  $scope.status = " "
  $scope.message = " "
  $scope.smsText = " "

  $scope.init()
  $scope.getData()
  $scope.getAge()
  $scope.getSchemes()
  return
