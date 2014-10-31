app.factory 'DataFactory', () ->
  Parse.initialize "l0JxXhedCkA8D1Z2EKyfG9AMbEF0L8oDW743XI13", "Sz4w7HWy38q4hqrIJxuGVkIGSFa3V0WoqElHKoqW"

  getDepartments = (callback) ->
    getDeptQuery = new Parse.Query 'Departments'
    getDeptQuery.find({
      success: (result) ->
        callback result
      error: (error) ->
        alert 'Error: ' + error.message
    })
    return

  getRoles = (callback) ->
    getRolesQuery = new Parse.Query 'Roles'
    getRolesQuery.find({
      success: (result) ->
        callback result
      error: (error) ->
        alert 'Error: ' + error.message
    })
    return

  getEducations = (callback) ->
    getEducationsQuery = new Parse.Query 'Educations'
    getEducationsQuery.find({
      success: (result) ->
        callback result
      error: (error) ->
        alert 'Error: ' + error.message
    })
    return

  getConstituencies = (callback) ->
    getConstituenciesQuery = new Parse.Query 'Constituencies'
    getConstituenciesQuery.find({
      success: (result) ->
        callback result
      error: (error) ->
        alert 'Error: ' + error.message
    })
    return

  getGPUs = (callback) ->
    getGPUsQuery = new Parse.Query 'GPUs'
    getGPUsQuery.find({
      success: (result) ->
        callback result
      error: (error) ->
        alert 'Error: ' + error.message
    })
    return

  getWards = (callback) ->
    getWardsQuery = new Parse.Query 'Wards'
    getWardsQuery.find({
      success: (result) ->
        callback result
      error: (error) ->
        alert 'Error: ' + error.message
    })
    return

  getGrievanceTypes = (callback) ->
    getGrievanceTypesQuery = new Parse.Query 'GrievanceTypes'
    getGrievanceTypesQuery.find({
      success: (result) ->
        callback result
      error: (error) ->
        alert 'Error: ' + error.message
    })
    return

  getSchemes = (deptName, callback) ->
    getSchemesQuery = new Parse.Query 'Schemes'
    getSchemesQuery.equalTo "departmentName", deptName
    getSchemesQuery.find({
      success: (result) ->
        callback result
      error: (error) ->
        alert 'Error: ' + error.message
    })
    return

  getCategories = (callback) ->
    getCategoriesQuery = new Parse.Query 'Categories'
    getCategoriesQuery.find({
      success: (result) ->
        callback result
      error: (error) ->
        alert 'Error: ' + error.message
    })
    return

  return {
    getDepartments: getDepartments
    getRoles: getRoles
    getEducations: getEducations
    getConstituencies: getConstituencies
    getGPUs: getGPUs
    getWards: getWards
    getGrievanceTypes: getGrievanceTypes
    getSchemes: getSchemes
    getCategories: getCategories
  }
