app.factory 'EditGrievanceFactory', ($http) ->
  Parse.initialize "l0JxXhedCkA8D1Z2EKyfG9AMbEF0L8oDW743XI13", "Sz4w7HWy38q4hqrIJxuGVkIGSFa3V0WoqElHKoqW"
  grievanceById = {}
  Grievance = Parse.Object.extend 'Grievances'
  update = (id, updatedRecord, callback) ->
    updateQuery = new Parse.Query Grievance
    updateQuery.equalTo 'objectId', id
    updateQuery.first({
      success: (object) ->
        object.save(null, {
          success: (object) ->
            object.set 'name', updatedRecord.name
            object.set 'fatherName', updatedRecord.fatherName
            object.set 'dob', updatedRecord.dob
            object.set 'phoneNumber', updatedRecord.phoneNumber
            object.set 'address', updatedRecord.address
            object.set 'education', updatedRecord.education
            object.set 'gpu', updatedRecord.gpu
            object.set 'constituency', updatedRecord.constituency
            object.set 'department', updatedRecord.department
            object.set 'grievanceType', updatedRecord.grievanceType
            object.set 'scheme', updatedRecord.scheme
            object.set 'requirement', updatedRecord.requirement
            object.set 'recommendedDoc', updatedRecord.recommendedDoc
            object.set 'coiDoc', updatedRecord.coiDoc
            object.set 'voterCard', updatedRecord.voterCard
            object.set 'casteCertificate', updatedRecord.casteCertificate
            object.set 'otherDoc', updatedRecord.otherDoc
            object.set 'note', updatedRecord.note
            object.set 'updatedUser', updatedRecord.updatedUser
            object.save()
            callback object
        })
    })
    return

  return {
    retrieveGrievance: grievanceById
    updateGrievance: update
  }

app.controller 'EditGrievanceController', ($scope, EditGrievanceFactory, DataFactory, $rootScope, $location) ->
  $scope.init = ->
    $scope.currentUser = $.parseJSON(localStorage.getItem 'Parse/l0JxXhedCkA8D1Z2EKyfG9AMbEF0L8oDW743XI13/currentUser')
    if $scope.currentUser
      $rootScope.userName = $scope.currentUser.username
      role = $scope.currentUser.role
      $rootScope.administrator = role == 'Admin'
      $rootScope.superUser = role == 'Super User'
    else
      $location.path '/error'
    #    $scope.$emit 'LOAD'
    return

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
    yearOfBirth = new Date(data._serverData.dob).getFullYear()
    $scope.age = currentYear - yearOfBirth
    return

  $(".date").datepicker autoclose: true
  data = EditGrievanceFactory.retrieveGrievance
  $scope.grievance = data
#  $scope.deptName = data._serverData.department
  $scope.recommendedDoc = data._serverData.recommendedDoc
  $scope.coiDoc = data._serverData.coiDoc
  $scope.voterCard = data._serverData.voterCard
  $scope.casteCertificate = data._serverData.casteCertificate
  $scope.otherDoc = data._serverData.otherDoc

  $scope.onFileSelect = ($files, fileName) ->
    $scope.invalidFile = false
    file = $files[0]
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

  $scope.updateGrievance = ->
    updateRecord = {
      name: $scope.grievance._serverData.name
      fatherName: $scope.grievance._serverData.fatherName
      dob: $scope.grievance._serverData.dob
      phoneNumber: $scope.grievance._serverData.phoneNumber
      address: $scope.grievance._serverData.address
      education: $scope.grievance._serverData.education
      gpu: $scope.grievance._serverData.gpu
      constituency: $scope.grievance._serverData.constituency
      department: $scope.grievance._serverData.department
      grievanceType: $scope.grievance._serverData.grievanceType
      scheme: $scope.grievance._serverData.scheme
      requirement: $scope.grievance._serverData.requirement
      recommendedDoc: $scope.recommendedDoc
      coiDoc: $scope.coiDoc
      voterCard: $scope.voterCard
      casteCertificate: $scope.casteCertificate
      otherDoc: $scope.otherDoc
      note: $scope.grievance._serverData.note
      updatedUser: $scope.currentUser.username
    }
    EditGrievanceFactory.updateGrievance($scope.grievance.id, updateRecord, (res) ->
      if res
        $scope.$apply(() ->
          $scope.successMessage = true;
        )
    )

  $scope.init()
  $scope.getData()
  $scope.getSchemes()
  $scope.getAge()
