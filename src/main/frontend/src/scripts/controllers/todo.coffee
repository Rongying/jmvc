class Controller
	constructor: (@$scope, @$location, @todoStorage, @filterFilter) ->
		@$scope.todos = @todoStorage
		todos = @$scope.todos
			
		@$scope.newTodo = ''
		@$scope.editedTodo = null
					
		@$scope.$watch 'todos', () ->
		  $scope.remainingCount = (@filterFilter todos, completed: false).length
		  $scope.doneCount = todos.length - @$scope.remainingCount
		  $scope.allChecked = if @$scope.remainingCount > 0 then false else true
		  @todoStorage.put todos
	   , true

angular.module('app').controller 'TodoController', ['$scope', '$location', 'todoStorage', 'filterFilter', Controller]