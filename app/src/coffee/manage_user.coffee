app.controller 'ManageUserController', ($scope, AdminUsersFactory, CreateUserFactory, $rootScope, $window, DataFactory) ->
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

  $scope.wards = DataFactory.wards
  $scope.userRoles = DataFactory.userRoles
  $scope.userById = AdminUsersFactory.userById
  $scope.successMessage = false
  $scope.errorMessage = false
  $scope.updateUser = ->
    updateRec =
      id: $scope.userById.id
      name: $scope.userById.name
      email: $scope.userById.email
      mobileNumber: $scope.userById.mobileNumber
      ward: $scope.userById.ward
      role: $scope.userById.role
      createdDate: $scope.userById.createdDate
      updatedDate: new Date().toLocaleString()

    $scope.$watch(CreateUserFactory.register(updateRec), (res) ->
      if res
        $scope.successMessage = true
        $scope.successText = 'User Updated Successfully.!'
      else
        $scope.errorMessage = true
        $scope.successText = 'User not updated.!'
    )
