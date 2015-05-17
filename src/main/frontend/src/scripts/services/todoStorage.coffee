class Service
	constructor: () ->
      STORAGE_ID = 'todos-angularjs-requirejs'
	  get: () ->
        JSON.parse localStorage.getItem STORAGE_ID || '[]'
      put: (todos) ->
		localStorage.setItem STORAGE_ID, JSON.stringify (todos);
	  
angular.module('app').service 'todoStorage', [Service]