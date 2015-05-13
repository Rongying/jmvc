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
			
		# Gets dependent components from bower
		# see bower.json file
		bower:
			install:
				options:
					cleanTargetDir: true
					copy: true
					layout: (type, component) ->
						path.join type
					targetDir: '.components/'
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
					cwd: '.components/'
					src: '**'
					dest: '<%= settings.tempDirectory %>'
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

	# Compiles the app with non-optimized build settings
	# Places the build artifacts in the dist directory
	# Enter the following command at the command line to execute this build task:
	# grunt build
	grunt.registerTask 'build', [
		'clean:working'
		'bower:install'
		'coffeelint'
		'copy:app'
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
				