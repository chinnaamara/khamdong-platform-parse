app.factory 'CategoriesFactory', () ->
  Parse.initialize "l0JxXhedCkA8D1Z2EKyfG9AMbEF0L8oDW743XI13", "Sz4w7HWy38q4hqrIJxuGVkIGSFa3V0WoqElHKoqW"

  Categories = Parse.Object.extend 'Categories'
  createCategory = (categoryName, callback) ->
    categories = new Categories()
    categories.save({categoryName: categoryName}, {
      success: (object) ->
        callback(object)
      error: (error) ->
        alert("Error: " + error.message)
    })
    return

  getCategories = (filterKey, callback) ->
    getQuery = new Parse.Query Categories
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
    getQuery = new Parse.Query Categories
    getQuery.count({ success: (result) -> callback result })
    return

  updateCategory = (data, callback) ->
    updateQuery = new Parse.Query Categories
    updateQuery.equalTo 'objectId', data.id
    updateQuery.first({
      success: (object) ->
        object.save(null, {
          success: (object) ->
            object.set 'categoryName', data.categoryName
            object.save()
            callback object
        })
    })
    return

  deleteCategory = (categoryId, callback) ->
    deleteQuery = new Parse.Query Categories
    deleteQuery.equalTo 'objectId', categoryId
    deleteQuery.each((object) ->
      object.destroy({
        success: (object) ->
          callback object
      })
    )
    return

  return {
    getCategories: getCategories
    createCategory: createCategory
    getCount: getCount
    updateCategory: updateCategory
    deleteCategory: deleteCategory
  }

app.controller 'CategoriesController', ($scope, $rootScope, CategoriesFactory, $location) ->
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

  $scope.getCategories = (filterKey) ->
    CategoriesFactory.getCategories(filterKey, (res) ->
      $scope.$apply(() ->
        $scope.categories = res
      )
    )

  $scope.btnAdd = ->
    $scope.modelTitle = 'Add New Category'
    $scope.categoryName = ''
    $scope.buttonText = 'Add'
    return

  $scope.btnEdit = (category) ->
    $scope.modelTitle = category.id
    $scope.buttonText = 'Update'
    $scope.categoryId = category.id
    $scope.categoryName = category._serverData.categoryName
    return

  $scope.addEditClick = ->
    data =
      categoryName: $scope.categoryName
    if $scope.buttonText == 'Add'
      addNewCategory(data)
    else
      data.id = $scope.categoryId
      updateCategory(data)
    return

  addNewCategory = (category) ->
    CategoriesFactory.createCategory(category.categoryName, (res) ->
      if res
        $scope.getCategories($scope.filterKey)
        $scope.NumberOfPages()
      else
        console.log 'Category not added.'
    )
    return

  updateCategory = (category) ->
    CategoriesFactory.updateCategory(category, (res) ->
      if res
        $scope.getCategories($scope.filterKey)
        $scope.NumberOfPages()
      else
        alert 'Category not updated.'
    )
    return

  $scope.deleteConformation = (category) ->
    $scope.deleteCategoryName = category._serverData.categoryName
    $scope.deleteCategoryId = category.id
    return

  $scope.deleteCategory = ->
    CategoriesFactory.deleteCategory($scope.deleteCategoryId, (res) ->
      $scope.getCategories($scope.filterKey)
      $scope.NumberOfPages()
    )
    return

  $scope.NumberOfPages = () ->
    CategoriesFactory.getCount((res) ->
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
    $scope.getCategories($scope.filterKey)
    $scope.noPrevious = false
    return

  $scope.pageBack = ->
    $scope.filterKey.pageNumber -= 1
    $scope.noPrevious = $scope.filterKey.pageNumber == 1 ? true : false
    $scope.getCategories($scope.filterKey)
    $scope.noNext = false
    return

  $scope.init()
  $scope.getCategories($scope.filterKey)
  $scope.NumberOfPages()
  return
