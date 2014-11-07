app.factory 'DepartmentsFactory', () ->
  Parse.initialize "l0JxXhedCkA8D1Z2EKyfG9AMbEF0L8oDW743XI13", "Sz4w7HWy38q4hqrIJxuGVkIGSFa3V0WoqElHKoqW"

  Departments = Parse.Object.extend 'Departments'
  createDepartment = (dept, callback) ->
    departments = new Departments
    departments.save({departmentCode: dept.departmentCode, departmentName: dept.departmentName}, {
      success: (object) ->
        callback object
      error: (error) ->
        alert("Error: " + error.message)
    })
    return

  readDepartments = (filterKey, callback) ->
    getQuery = new Parse.Query Departments
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
    getQuery = new Parse.Query Departments
    getQuery.count({ success: (result) -> callback result })
    return

  updateDepartment = (data, callback) ->
    updateQuery = new Parse.Query Departments
    updateQuery.equalTo 'objectId', data.id
    updateQuery.first({
      success: (object) ->
        object.save(null, {
          success: (object) ->
            object.set 'departmentCode', data.departmentCode
            object.set 'departmentName', data.departmentName
            object.save()
            callback object
        })
    })
    return

  deleteDepartment = (deptId, callback) ->
    deleteQuery = new Parse.Query Departments
    deleteQuery.equalTo 'objectId', deptId
    deleteQuery.each((object) ->
      object.destroy({
        success: (object) ->
          callback object
      })
    )
    return

  return {
    addNewDepartment: createDepartment
    getDepartments: readDepartments
    updateDepartment: updateDepartment
    delete: deleteDepartment
    getCount: getCount
  }


app.controller "AddDepartmentController", ($scope, DepartmentsFactory, $rootScope, $location) ->
  $scope.filterKey = {
    pageNumber: 1
    pageLimit: 8
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

  $scope.getDepartments = (filterKey) ->
    DepartmentsFactory.getDepartments(filterKey, (res) ->
      $scope.$apply(() ->
        $scope.departments = res
      )
    )
    return

  $scope.btnAdd = ->
    if $scope.currentUser.role == 'Admin'
      $scope.modelTitle = 'Add New Department'
      $scope.departmentName = ''
      $scope.departmentCode = ''
      $scope.buttonText = 'Add'
    else
      alert 'You are not authorized!'
    return

  $scope.btnEdit = (dept) ->
    if $scope.currentUser.role == 'Admin'
      $scope.modelTitle = dept.id
      $scope.buttonText = 'Update'
      $scope.deptId = dept.id
      $scope.departmentCode = dept._serverData.departmentCode
      $scope.departmentName = dept._serverData.departmentName
    else
      alert 'You are not authorized!'
    return

  $scope.addEditClick = ->
    data =
      departmentCode: $scope.departmentCode
      departmentName: $scope.departmentName
    if $scope.buttonText == 'Add'
      addNewDepartment(data)
    else
      data.id = $scope.deptId
      updateDepartment(data)
    return

  addNewDepartment = (dept) ->
    if $scope.currentUser.role == 'Admin'
      DepartmentsFactory.addNewDepartment(dept, (res) ->
        if res
          $scope.getDepartments($scope.filterKey)
          $scope.NumberOfPages()
        else
          alert 'Department not Added.'
      )
    else
      alert 'You are not authorized!'
    return

  updateDepartment = (dept) ->
    if $scope.currentUser.role == 'Admin'
      DepartmentsFactory.updateDepartment(dept, (res) ->
        if res
          $scope.getDepartments($scope.filterKey)
          $scope.NumberOfPages()
        else
          alert 'Department not updated.'
      )
    else
      alert 'You are not authorized!'
    return

  $scope.deleteConformation = (dept) ->
    if $scope.currentUser.role == 'Admin'
      $scope.deleteDeptName = dept._serverData.departmentName
      $scope.deleteDeptId = dept.id
    else
      alert 'You are not authorized!'
    return

  $scope.deleteDepartment = ->
    if $scope.currentUser.role == 'Admin'
      DepartmentsFactory.delete($scope.deleteDeptId, (res) ->
        $scope.getDepartments($scope.filterKey)
        $scope.NumberOfPages()
      )
    else
      alert 'You are not authorized!'
    return

  $scope.NumberOfPages = () ->
    DepartmentsFactory.getCount((res) ->
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
    $scope.getDepartments($scope.filterKey)
    $scope.noPrevious = false
    return

  $scope.pageBack = ->
    $scope.filterKey.pageNumber -= 1
    $scope.noPrevious = $scope.filterKey.pageNumber == 1 ? true : false
    $scope.getDepartments($scope.filterKey)
    $scope.noNext = false
    return

  $scope.init()
  $scope.getDepartments($scope.filterKey)
  $scope.NumberOfPages()
  return
