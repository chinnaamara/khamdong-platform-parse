app.factory 'CategoriesFactory', ($firebase, BASEURI) ->

  categoriesRef = new Firebase BASEURI + 'categories/'
  categories = $firebase categoriesRef

  getCategories = (count, callback) ->
    categoriesRef.startAt().limit(count).on('value', (res) ->
      callback _.values res.val()
    )

  createCategory = (category) ->
    addRef = new Firebase BASEURI + 'categories/' + category.categoryId
    addRef.child('id').set category.categoryId
    addRef.child('name').set category.categoryName
    addRef.child('createdDate').set category.createdDate
    addRef.child('updatedDate').set category.updatedDate
    return 'true'

  deleteCategory = (id) ->
    deleteRef = categoriesRef.child(id)
    deleteRef.remove()
    return 'true'

  return {
    categories: categories
    getCategories: getCategories
    categoriesRef: categoriesRef
    createCategory: createCategory
    delete: deleteCategory
  }

app.controller 'CategoriesController', ($scope, $rootScope, CategoriesFactory, $window) ->
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

  $scope.categories = CategoriesFactory.categories

  catId = (cat) ->
    date = new Date()
    refID = date.getTime()
    str1 = cat.substring(0, 2).toUpperCase()
    refID + str1

  $scope.btnAdd = ->
    $scope.modelTitle = 'Add New Category'
    $scope.categoryName = ''
    $scope.buttonText = 'Add'

  $scope.addNewCategory = ->
    if $scope.buttonText == 'Add'
      category =
        categoryId: catId($scope.categoryName)
        categoryName: $scope.categoryName
        createdDate: new Date().toLocaleString()
        updatedDate: new Date().toLocaleString()
    else
      category =
        categoryId: $scope.categoryById.categoryId
        categoryName: $scope.categoryName
        createdDate: $scope.categoryById.createdDate
        updatedDate: new Date().toLocaleString()

    $scope.$watch(CategoriesFactory.createCategory(category), (res) ->
      if res
        console.log 'category added'
      else
        console.log 'category not added'
    )

  $scope.categoryName = ''
  $scope.categoryById = {}
  $scope.editCategory = (cat) ->
    $scope.modelTitle = 'Edit Category'
    $scope.buttonText = 'Update'
    $scope.categoryById.categoryId = cat.id
    $scope.categoryName = cat.name
    $scope.categoryById.createdDate = cat.createdDate

  $scope.deleteCategory = (cat) ->
    $scope.$watch(CategoriesFactory.delete(cat.id), (res) ->
      if res
        console.log 'deleted success'
      else
        console.log 'not deleted'
    )
