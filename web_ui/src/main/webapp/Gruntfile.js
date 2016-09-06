module.exports = function(grunt) {
    grunt.loadNpmTasks('grunt-contrib-jshint');
    grunt.loadNpmTasks('grunt-contrib-clean');
    grunt.loadNpmTasks('grunt-contrib-copy');
    grunt.loadNpmTasks('grunt-contrib-connect');
    grunt.loadNpmTasks('grunt-contrib-compress');
    grunt.loadNpmTasks('grunt-contrib-concat');
    grunt.loadNpmTasks('grunt-contrib-uglify');
    grunt.loadNpmTasks('grunt-html2js');
    grunt.loadNpmTasks('grunt-contrib-watch');
    grunt.loadNpmTasks('grunt-bower-task');
    grunt.loadNpmTasks('grunt-responsive-images');
    grunt.loadNpmTasks('grunt-contrib-compass');
    grunt.loadNpmTasks('grunt-ng-annotate');
    grunt.loadNpmTasks('grunt-angular-templates');
    grunt.loadNpmTasks('grunt-elm');

    grunt.initConfig({
        'pkg': grunt.file.readJSON('package.json'),

        'bower': {
            install: {
                options: {
                    install: true,
                    copy: false,
                    targetDir: 'assets/bower_components',
                    cleanTargetDir: false
                }
            }
        },

        'jshint': {
            'beforeconcat': ['src/js/**/*.js'],
        },

        'elm': {
            compile: {
                files: {
                    'app/auth_web_ui.js': ['src/elm/**/*.elm']
                }
            }
        },

        'html2js': {
            dist: {
                src: ['src/views/*.html'],
                dest: 'tmp/templates.js'
            }
        },

        'copy': {
            'dist': {
                files: [{
                    expand: true,
                    cwd: 'src/views',
                    src: ['**'],
                    dest: 'app/views'
                }, {
                    expand: true,
                    cwd: 'src/styles',
                    src: ['**'],
                    dest: 'app/styles'
                }, {
                    expand: true,
                    cwd: 'src',
                    src: ['index.html'],
                    dest: 'app'
                }],
            }
        },

        ngtemplates: {
            authService: {
                options: {
                    prefix: '/',
                    htmlmin: {
                        collapseBooleanAttributes: true,
                        collapseWhitespace: true,
                        removeAttributeQuotes: true,
                        removeComments: true,
                        removeEmptyAttributes: true,
                        removeRedundantAttributes: true,
                        removeScriptTypeAttributes: true,
                        removeStyleLinkTypeAttributes: true
                    }
                },
                src: 'app/views/**.html',
                dest: 'app/template.js'
            }
        },

        'concat': {
            options: {
                separator: ';\n'
            },
            'sources': {
                'src': [
                    'src/js/**/*.js'
                ],
                'dest': 'app/<%= pkg.name %>.js'
            },
            'libs': {
                'src': [
                    'app/libs/jquery/dist/jquery.min.js',
                    'app/libs/angular/angular.min.js',
                    'app/libs/bootstrap/dist/js/bootstrap.min.js',
                    'app/libs/angular-bootstrap/ui-bootstrap-tpls.min.js',
                    'app/libs/ng-table/dist/ng-table.min.js',
                    'app/libs/angular-resource/angular-resource.min.js',
                    'app/libs/angular-ui-router/release/angular-ui-router.min.js',
                    'app/libs/angular-toastr/dist/angular-toastr.tpls.min.js',
                    'app/libs/angular-ui-router-menus/dist/angular-ui-router-menus.min.js',
                    'app/libs/satellizer/satellizer.min.js',

                    'app/<%= pkg.name %>.js',
                    'app/template.js'
                ],
                'dest': 'app/<%= pkg.name %>.js'
            }
        },

        'ngAnnotate': {
            options: {
                singleQuotes: true
            },
            dist: {
                files: [{
                    expand: true,
                    src: ['app/<%= pkg.name %>.js'],
                    ext: '.annotated.js',
                    extDot: 'last'
                }, ]
            }
        },

        'uglify': {
            'options': {
                'mangle': false
            },
            'dist': {
                'files': {
                    'app/<%= pkg.name %>.min.js': ['app/<%= pkg.name %>.annotated.js']
                }
            }
        },

        'responsive_images': {
            'dist': {
                options: {
                    engine: 'im',
                    quality: '25',
                    sizes: [{
                        width: '100%',
                        name: 'large',
                        suffix: '.x2'
                    }, {
                        width: '66%',
                        name: 'medium',
                        suffix: '.x2'
                    }, {
                        width: '44%',
                        name: 'small',
                        suffix: '.x2'
                    }, {
                        width: '50%',
                        name: 'large'
                    }, {
                        width: '33%',
                        name: 'medium'
                    }, {
                        width: '22%',
                        name: 'small'
                    }]
                },
                files: [{
                    expand: true,
                    cwd: 'src/images',
                    src: ['**/*.{jpg,gif,png}'],
                    dest: 'app/images'
                }]
            }
        },

        'compress': {
            dist: {
                options: {
                    archive: 'dist/<%= pkg.name %>-<%= pkg.version %>.zip'
                },
                files: [{
                    src: ['app/**', 'server.js'],
                    dest: '/'
                }]
            }
        },

        'connect': {
            server: {
                options: {
                    hostname: 'localhost',
                    port: 9071,
                    base: 'app'
                }
            }
        },

        'watch': {
            'dev': {
                files: ['Gruntfile.js', 'bower.json', 'elm-package.json', 'server.js', 'config.rb', 'src/**'],
                tasks: ['build'],
                options: {
                    atBegin: true
                }
            },
            'min': {
                files: ['Gruntfile.js', 'src/**'],
                tasks: ['package'],
                options: {
                    atBegin: true
                }
            }
        },

        'clean': {
            temp: {
                src: ['tmp', 'app', 'dist']
            }
        },
    });

    grunt.registerTask('dev', ['bower', 'connect:server', 'watch:dev']);
    grunt.registerTask('minified', ['bower', 'connect:server', 'watch:min']);
    grunt.registerTask('build', ['bower', 'html2js', 'copy', 'elm', 'concat:libs', 'responsive_images']);
    grunt.registerTask('package', ['build', 'uglify', 'compress']);
};
