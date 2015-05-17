path = require 'path'

module.exports = (grunt) ->
	require('load-grunt-tasks')(grunt)
	require('time-grunt')(grunt)
	pkg = require './package.json'
	
	grunt.initConfig
		settings:
			distDirectory: 'dist'
			srcDirectory: 'src'
			tempDirectory: '.temp'
			bowerDirectory: '.components'
		# Gets dependent components from bower
		# see bower.json file
		bower:
			install:
				options:
					cleanTargetDir: true
					copy: true
					layout: (type, component, source) ->
						if type is '__untyped__' then type = source.substring (source.lastIndexOf '.') + 1
						path.join component, type
					targetDir: '<%= settings.bowerDirectory %>'
			uninstall:
				options:
					cleanBowerDir: true
					copy: false
					install: false
		# Deletes dist and .temp directories
		# The .temp directory is used during the build process
		# The dist directory contains the artifacts of the build
		# These directories should be deleted before subsequent builds
		# These directories are not committed to source control
		clean:
			working: [
				'<%= settings.tempDirectory %>'
				'<%= settings.distDirectory %>'
			]
		# Compiles CoffeeScript (.coffee) files to JavaScript (.js)
		coffee:
			app:
				files: [
					cwd: '<%= settings.tempDirectory %>'
					src: '**/*.coffee'
					dest: '<%= settings.tempDirectory %>'
					expand: true
					ext: '.js'
				]
				options:
					sourceMap: true
		# Lints CoffeeScript files
		coffeelint:
			app:
				files: [
					cwd: ''
					src: [
						'src/**/*.coffee'
						'!src/scripts/libs/**'
					]
				]
				options:
					indentation:
						value: 1
					max_line_length:
						level: 'ignore'
					no_tabs:
						level: 'ignore'
		# Copies directories and files from one location to another
		copy:
			app:
				files: [
					cwd: '<%= settings.srcDirectory %>'
					src: '**'
					dest: '<%= settings.tempDirectory %>'
					expand: true
				,
					cwd: '<%= settings.bowerDirectory %>'
					src: '**'
					dest: '<%= settings.tempDirectory %>/vendors'
					expand: true
				]
			dev:
				cwd: '<%= settings.tempDirectory %>'
				src: '**'
				dest: '<%= settings.distDirectory %>'
				expand: true
			prod:
				files: [
					cwd: '<%= settings.tempDirectory %>'
					src: [
						'**/*.{eot,svg,ttf,woff}'
						'**/*.{gif,jpeg,jpg,png,svg,webp}'
						'index.html'
						'scripts/ie.min.*.js'
						'scripts/scripts.min.*.js'
						'styles/styles.min.*.css'
					]
					dest: '<%= settings.distDirectory %>'
					expand: true
				]
		# Convert CoffeeScript classes to AngularJS modules
		ngClassify:
			app:
				files: [
					cwd: '<%= settings.tempDirectory %>'
					src: '**/*.coffee'
					dest: '<%= settings.tempDirectory %>'
					expand: true
				]
		shimmer:
			dev:
				cwd: '.temp/scripts'
				src: [
					'**/*.{coffee,js}'
					'!libs/angular.{coffee,js}'
					'!libs/angular-route.{coffee,js}'
					'!libs/require.{coffee,js}'
				]
				order: [
					'libs/angular.min.js'
					'NGAPP':
						'ngRoute': 'libs/angular-route.min.js'
				]
				require: 'NGBOOTSTRAP'
		# Run tasks when monitored files change
		watch:
			basic:
				files: [
					'src/fonts/**'
					'src/images/**'
					'src/scripts/**/*.js'
					'src/styles/**/*.css'
					'src/**/*.html'
				]
				tasks: [
					'copy:app'
					'copy:dev'
				]
				options:
					livereload: true
					nospawn: true
			coffee:
				files: 'src/scripts/**/*.coffee'
				tasks: [
					'clean:working'
					'coffeelint'
					'copy:app'
					'shimmer:dev'
					'coffee:app'
					'copy:dev'
				]
				options:
					livereload: true
					nospawn: true
		# ensure only tasks are executed for the changed file
		# without this, the tasks for all files matching the original pattern are executed
		grunt.event.on 'watch', (action, filepath, key) ->
			file = filepath.substr(4) # trim "src/" from the beginning.  I don't like what I'm doing here, need a better way of handling paths.
			dirname = path.dirname file
			ext = path.extname file
			basename = path.basename file, ext

			grunt.config ['copy', 'app'],
				cwd: 'src/'
				src: file
				dest: '.temp/'
				expand: true

			copyDevConfig = grunt.config ['copy', 'dev']
			copyDevConfig.src = file

			if key is 'coffee'
				# delete associated temp file prior to performing remaining tasks
				# without doing so, shimmer may fail
				grunt.config ['clean', 'working'], [
					path.join('.temp', dirname, "#{basename}.{coffee,js,js.map}")
				]

				copyDevConfig.src = [
					path.join(dirname, "#{basename}.{coffee,js,js.map}")
					'scripts/main.{coffee,js,js.map}'
				]

				coffeeConfig = grunt.config ['coffee', 'app', 'files']
				coffeeConfig.src = file
				coffeeLintConfig = grunt.config ['coffeelint', 'app', 'files']
				coffeeLintConfig = filepath

				grunt.config ['coffee', 'app', 'files'], coffeeConfig
				grunt.config ['coffeelint', 'app', 'files'], coffeeLintConfig

			grunt.config ['copy', 'dev'], copyDevConfig
				
	# Compiles the app with non-optimized build settings
	# Places the build artifacts in the dist directory
	# Enter the following command at the command line to execute this build task:
	# grunt build
	grunt.registerTask 'build', [
		'clean:working'
		'bower:install'
		'copy:app'
		'shimmer:dev'
		'ngClassify'
		'coffee:app'
		'copy:dev'
	]

	# Compiles the app with non-optimized build settings
	# Places the build artifacts in the dist directory
	# Opens the app in the default browser
	# Watches for file changes, and compiles and reloads the web browser upon change
	# Enter the following command at the command line to execute this build task:
	# grunt or grunt default
	grunt.registerTask 'default', [
		'build'
	]

	# Identical to the default build task
	# Compiles the app with non-optimized build settings
	# Places the build artifacts in the dist directory
	# Opens the app in the default browser
	# Watches for file changes, and compiles and reloads the web browser upon change
	# Enter the following command at the command line to execute this build task:
	# grunt dev
	grunt.registerTask 'dev', [
		'default'
	]

	# Compiles the app with optimized build settings
	# Places the build artifacts in the dist directory
	# Enter the following command at the command line to execute this build task:
	# grunt prod
	grunt.registerTask 'prod', [
		'clean:working'
		'bower:install'
		'coffeelint'
		'copy:app'
		'coffee:app'
		'copy:prod'
	]
				