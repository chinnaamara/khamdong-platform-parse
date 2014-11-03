app.factory 'NewGrievanceFactory', ($http) ->

  Parse.initialize "l0JxXhedCkA8D1Z2EKyfG9AMbEF0L8oDW743XI13", "Sz4w7HWy38q4hqrIJxuGVkIGSFa3V0WoqElHKoqW"
  Grievances = Parse.Object.extend 'Grievances'

  submitGrievance = (data, callback) ->
    grievances = new Grievances()
    grievances.save({name: data.name
      , fatherName: data.fatherName
      , dob: data.dob
      , phoneNumber: data.phoneNumber
      , address: data.address
      , education: data.education
      , gpu: data.gpu
      , ward: data.ward
      , constituency: data.constituency
      , department: data.department
      , scheme: data.scheme
      , requirement: data.requirement
      , grievanceType: data.grievanceType
      , note: data.note
      , recommendedDoc: data.recommendedDoc
      , coiDoc: data.coiDoc
      , voterCard: data.voterCard
      , casteCertificate: data.casteCertificate
      , otherDoc: data.otherDoc
      , applicationDate: data.applicationDate
      , respondedDate: data.respondedDate
      , status: data.status
      , message:data.message
      , submittedUser: data.submittedUser
      , updatedUser: data.updatedUser
      }, {
      success: (object) ->
        callback(object)
      error: (error) ->
        alert("Error: " + error.message)
    })
    return

  sendSms = (id, data, callback) ->
    message = data.message + id + '.'
    $http
    .post('http://api.mVaayoo.com/mvaayooapi/MessageCompose?user=Dilip@cannybee.in:8686993306&senderID=TEST SMS&receipientno=' + data.mobile + '&msgtxt= ' + message + ' &state=4')
    .success((data) ->
      callback data
    )
    .error((status) ->
      callback status.responseText
    )
    return

  return {
    submitGrievance: submitGrievance
    sendSms: sendSms
  }

app.controller 'NewGrievanceController', ($scope, $location, NewGrievanceFactory, DataFactory, $rootScope) ->
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
  $scope.init()

  $scope.getData = ->
    DataFactory.getEducations((res) ->
      $scope.$apply(() ->
        $scope.education = res
      )
    )
    DataFactory.getGPUs((res) ->
      $scope.$apply(() ->
        $scope.gpus = res
      )
    )
    DataFactory.getConstituencies((res) ->
      $scope.$apply(() ->
        $scope.constituencies = res
      )
    )
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
    DataFactory.getWards((res) ->
      $scope.$apply(() ->
        $scope.wards = res
      )
    )
    return

  $scope.getData()

  $scope.getSchemes = ->
    DataFactory.getSchemes($scope.grievance.department, (res) ->
      $scope.$apply(() ->
        $scope.schemes = res
      )
    )

  $scope.address = " "
  $scope.note = " "
  $scope.recommendedDoc = ""
  $scope.coiDoc = ""
  $scope.voterCard = ""
  $scope.casteCertificate = ""
  $scope.otherDoc = ""

  $scope.onFileSelect = ($files, fileName) ->
    $scope.invalidFile = false
    file = $files[0]
#    console.log file.name
    if file.size < 1000 * 20 && file.type != 'application/pdf'
      reader = new FileReader()
      reader.readAsArrayBuffer file
      reader.onload = (e) ->
        if fileName == 'recommended'
          $scope.recommendedDoc = arrayBufferToBase64 e.target.result
          $scope.$apply(() ->
            $scope.invalidRecommendedDoc = false
          )
        else if fileName == 'coi'
          $scope.coiDoc = arrayBufferToBase64 e.target.result
          $scope.$apply(() ->
            $scope.invalidCOIDoc = false
          )
        else if fileName == 'voter'
          $scope.voterCard = arrayBufferToBase64 e.target.result
          $scope.$apply(() ->
            $scope.invalidVoterId = false
          )
        else if fileName == 'caste'
          $scope.casteCertificate = arrayBufferToBase64 e.target.result
          $scope.$apply(() ->
            $scope.invalidCasteCertificate = false
          )
        else
          $scope.otherDoc = arrayBufferToBase64 e.target.result
          $scope.$apply(() ->
            $scope.invalidOtherDoc = false
          )
        return
    else
      if fileName == 'recommended'
        $scope.invalidRecommendedDoc = true
        $scope.recommendedDoc = ''
      else if fileName == 'coi'
        $scope.invalidCOIDoc = true
        $scope.coiDoc = ''
      else if fileName == 'voter'
        $scope.invalidVoterId = true
        $scope.voterCard = ''
      else if fileName == 'caste'
        $scope.invalidCasteCertificate = true
        $scope.casteCertificate = ''
      else
        $scope.invalidOtherDoc = true
        $scope.otherDoc = ''
    return

  arrayBufferToBase64 = (arrayBuffer) ->
     binary = ''
     bytes = new Uint8Array arrayBuffer
     _.forEach(_.range(bytes.length),(e) ->
       binary += String.fromCharCode bytes[e]
      )
     btoa binary

#  $scope.sendSms = () ->
#    $.ajax({
#      url: "http://api.mVaayoo.com/mvaayooapi/MessageCompose?user=technorrp@gmail.com:Design_20&senderID=TEST SMS&receipientno=9000991520&msgtxt= final message from chinna by mVaayoo API&state=4",
#      type: 'GET',
#      dataType: 'json',
#      success: () ->
#        alert 'successfully sent'
#      , error: (status) ->
#        alert status.responseText
#    })

  $scope.ward = $scope.currentUser.ward
  $scope.printButton = true
  $scope.createGrievance = () ->
    newGrievance = {
      name: $scope.grievance.name
      fatherName: $scope.grievance.fatherName
      dob: $scope.grievance.dob
      phoneNumber: $scope.grievance.phoneNumber
      address: $scope.address
      education: $scope.grievance.education
      gpu: $scope.grievance.gpu
      ward: $scope.currentUser.ward
      constituency: $scope.grievance.constituency
      department: $scope.grievance.department
      grievanceType: $scope.grievance.grievanceType
      scheme: $scope.grievance.scheme
      requirement: $scope.grievance.requirement
      recommendedDoc: $scope.recommendedDoc
      coiDoc: $scope.coiDoc
      voterCard: $scope.voterCard
      casteCertificate: $scope.casteCertificate
      otherDoc: $scope.otherDoc
      note: $scope.note
      applicationDate: new Date().toLocaleString()
      respondedDate: "--/--/----"
      status: "Open"
      message: "Waiting"
      submittedUser: $scope.currentUser.username
      updatedUser: $scope.currentUser.username
    }
    $scope.new_grievance = newGrievance
    smsData = {
      mobile: $scope.grievance.phoneNumber
      message: "Hi " + $scope.grievance.name + ", your grievance request is registered at Khamdong, by " + $scope.ward + " ward. Your reference number is: "
    }

    NewGrievanceFactory.submitGrievance(newGrievance, (res) ->
#      console.log res.id
      if res
        $scope.printButton = false
        $scope.$apply(() ->
          $scope.successMessage = true;
          $scope.new_grievance.referenceNum = res.id
        )
#        alert 'Grievance Reference Id is: ' + res.id
        NewGrievanceFactory.sendSms(res.id, smsData, (status) ->
          if status
            console.log "sms sent to " + smsData.mobile
        )
      )

  $scope.calculateAgeOnDOB = () ->
    dob = $scope.grievance.dob
    date1 = new Date()
    date2 = new Date(dob)
    if dob
      y1 = date1.getFullYear()
      y2 = date2.getFullYear()
      $scope.grievance.age = y1 - y2 + " years"
      return
    else
      $scope.grievance.age = "Invalid Date"

  $scope.printPdf = ->
    printElement(document.getElementById 'printThis')
    window.print()

  printElement = (elem) ->
    domClone = elem.cloneNode true
    $printSection = document.getElementById 'printSection'
    unless $printSection
      $printSection = document.createElement 'div'
      $printSection.id = 'printSection'
      document.body.appendChild $printSection
    $printSection.innerHTML = ''
    $printSection.appendChild domClone
    return

  $scope.notRecommended = true
  $scope.checkboxEvent = (val) ->
    if val == true
      $scope.fileTypeInfo = true
      $scope.notRecommended = false
    else
      $scope.fileTypeInfo = false
      $scope.notRecommended = true

  $(".date").datepicker autoclose: true
#  $(".date").datepicker({
#    viewMode: 'years'
#    format: 'dd/mm/yyyy'
#    autoclose: true
#  })


app.directive 'SampleDirective', () ->
  return {
    restrict: 'E'
    template: '<input type="text">'
  }
