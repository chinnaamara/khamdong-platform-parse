app = angular.module 'Khamdong', ['ui.router', 'angularFileUpload', 'ngTable', 'ui.bootstrap']
app.constant 'AUTH_EVENTS', {
  loginSuccess: 'auth-login-success'
  loginFailed: 'auth-login-failed'
  logoutSuccess: 'auth-logout-success'
  sessionTimeout: 'auth-session-timeout'
  notAuthenticated: 'auth-not-authenticated'
  notAutherized: 'auth-not-autherized'
}
app.constant 'USER_ROLES', {
  all: '*'
  admin: 'admin'
  superUser: 'superUser'
  user: 'user'
}
app.config(($stateProvider) ->
  $stateProvider
  .state('start', {
      url: ''
      views: {
        'viewA@': {templateUrl: 'html/nav.html', controller: 'LoginController'}
        'viewB@': {templateUrl: 'html/login.html', controller: 'LoginController'}
      }
    })
  .state('login', {
      url: '/login'
      views: {
        'viewA@': {templateUrl: 'html/nav.html', controller: 'LoginController'}
        'viewB@': {templateUrl: 'html/login.html', controller: 'LoginController'}
      }
    })
  .state('logout', {
      url: '/logout'
      views: {
        'viewA@': {templateUrl: 'html/nav.html', controller: 'LoginController'}
        'viewB@': {templateUrl: 'html/login.html', controller: 'LoginController'}
      }
    })
  .state('newGrievance', {
      url: '/new/grievance'
      views: {
        'viewA@': {templateUrl: 'html/nav.html', controller: 'LoginController'}
        'viewB@': {templateUrl: 'html/new_grievance.html', controller: 'NewGrievanceController'}
      }
    })
  .state('admin', {
      url: '/admin'
      views: {
        'viewA@': {templateUrl: 'html/nav.html', controller: 'LoginController'}
        'viewB@': {templateUrl: 'html/dashboard.html', controller: 'DashboardController'}
      }
    })
  .state('userDashboard', {
      url: '/user/grievances'
      views: {
        'viewA@': {templateUrl: 'html/nav.html', controller: 'LoginController'}
        'viewB@': {templateUrl: 'html/user_grievances.html', controller: 'GrievancesController'}
      }
    })
  .state('details', {
      url: '/details'
      views: {
        'viewA@': {templateUrl: 'html/nav.html', controller: 'LoginController'}
        'viewB@': {templateUrl: 'html/details.html', controller: 'DetailsController'}
      }
    })
  .state('newDepartment', {
      url: '/new_department'
      views: {
        'viewA@': {templateUrl: 'html/nav.html', controller: 'LoginController'}
        'viewB@': {templateUrl: 'html/new_department.html', controller: 'AddDepartmentController'}
      }
    })
  .state('newScheme', {
      url: '/new_scheme'
      views: {
        'viewA@': {templateUrl: 'html/nav.html', controller: 'LoginController'}
        'viewB@': {templateUrl: 'html/new_scheme.html', controller: 'AddSchemeController'}
      }
    })
  .state('createUser', {
      url: '/new_user'
      views: {
        'viewA@': {templateUrl: 'html/nav.html', controller: 'LoginController'}
        'viewB@': {templateUrl: 'html/create_user.html', controller: 'CreateUserController'}
      }
    })
  .state('editGrievance', {
      url: '/grievance/edit'
      views: {
        'viewA@': {templateUrl: 'html/nav.html', controller: 'LoginController'}
        'viewB@': {templateUrl: 'html/edit_grievance.html', controller: 'EditGrievanceController'}
      }
    })
  .state('error', {
      url: '/error'
      views: {
        'viewA@': {templateUrl: 'html/nav.html', controller: 'LoginController'}
        'viewB@': {templateUrl: 'html/error.html'}
      }
    })
  .state('users_list', {
      url: '/superuser/userslist'
      views: {
        'viewA@': {templateUrl: 'html/nav.html', controller: 'LoginController'}
        'viewB@': {templateUrl: 'html/users_list.html', controller: 'MembersController'}
      }
    })
  .state('adminUsers', {
      url: '/admin/users'
      views: {
        'viewA@': {templateUrl: 'html/nav.html', controller: 'LoginController'}
        'viewB@': {templateUrl: 'html/users_admin.html', controller: 'AdminUsersController'}
      }
    })
  .state('transferUsers', {
      url: '/admin/users/manage'
      views: {
        'viewA@': {templateUrl: 'html/nav.html', controller: 'LoginController'}
        'viewB@': {templateUrl: 'html/transfer_user.html', controller: 'ManageUserController'}
      }
    })
  .state('categories', {
      url: '/superuser/categories'
      views: {
        'viewA@': {templateUrl: 'html/nav.html', controller: 'LoginController'}
        'viewB@': {templateUrl: 'html/categories.html', controller: 'CategoriesController'}
      }
    })
  .state('wards', {
      url: '/admin/wards'
      views: {
        'viewA@': {templateUrl: 'html/nav.html', controller: 'LoginController'}
        'viewB@': {templateUrl: 'html/wards.html', controller: 'WardsController'}
      }
    })
  .state('sentMessages', {
      url: '/superuser/messages'
      views: {
        'viewA@': {templateUrl: 'html/nav.html', controller: 'LoginController'}
        'viewB@': {templateUrl: 'html/sent_messages.html', controller: 'MessagesController'}
      }
    })
  return
)
