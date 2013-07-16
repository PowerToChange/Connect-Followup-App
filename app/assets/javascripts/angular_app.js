window.App = angular.module('connectapp', []);

App.config(["$routeProvider",function($routeProvider) {
  $routeProvider
    .when('/',{
      templateUrl: "/assets/index.html",
      controller: "ReportCtrl"
    })
    .when('/not_work',{
      templateUrl: "/assets/not_work.html",
      controller: "ReportCtrl"
    })
    .when('/worked_out',{
      templateUrl: "/assets/worked_out.html",
      controller: "ReportCtrl"
    })
    .when('/ending',{
      templateUrl: "/assets/ending.html",
      controller: "ReportCtrl"
    })
    .when('/continuing',{
      templateUrl: "/assets/continuing.html",
      controller: "ReportCtrl"
    })
}]);

App.run(["$rootScope", function($rootScope){
  $rootScope.data = [];
}]);

App.controller("ReportCtrl", ["$scope","$routeParams", "$rootScope",function($scope,$routeParams,$rootScope) {
  $scope.goBack = function() {
    window.history.back();
  };
  $scope.addData = function(val) {
    $rootScope.data.push(val);
  };
  $scope.submit = function(val) {
    $scope.addData(val);
    console.log("Submitting to remote server....." + $rootScope.data);
  }
}]);

App.directive("progressbar", ["$rootScope", function($rootScope) {
  return {
    scope: {
      percentage: "@",
      message: "@"
    },
    restrict: "E",
    templateUrl: "/assets/progress.html",
    link: function() {
      console.log($rootScope.data);
    }
  }
}]);

App.directive("selectedvalues", function() {
  return {
    restrict: "E",
    template: "<div>{{data.message}}</div>"
  }
});