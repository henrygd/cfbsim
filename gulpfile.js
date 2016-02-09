var gulp = require('gulp'),
    uglifyJs = require('gulp-uglify'),
    uglifyCss = require('gulp-uglifycss'),
    rename = require('gulp-rename'),
    autoprefixer = require('gulp-autoprefixer'),
    gls = require('gulp-live-server'),
    sass = require('gulp-sass'),
    ghPages = require('gulp-gh-pages'),
    concat = require('gulp-concat'),
    inject = require('gulp-inject');

var sassFiles = ['css/**/*.scss'];
var jsFiles = ['js/*.js'];

// INJECT STATIC FILE LINKS INTO HTML (DEV)
gulp.task('index', function () {
  var target = gulp.src('./index.html');
  var sources = gulp.src(['js/**/*.js', 'css/**/*.css'], {read: false});
  return target.pipe(inject(sources))
    .pipe(gulp.dest('./'))
    .pipe(gulp.dest('build/'));
});

// JAVASCRIPT TASKS
// uglifies javascript
gulp.task('uglifyjs', function() {
  return gulp.src(jsFiles)
    .pipe(concat('scripts.min.js'))
    .pipe(uglifyJs())
    .on('error', console.error.bind(console))
    .pipe(gulp.dest('./js/min/'));
});

// STYLE TASKS
// prefixes / uglifies css
gulp.task('css', function(){
  gulp.src(sassFiles)
    .pipe(sass().on('error', sass.logError))
    // minify
    .pipe(uglifyCss())
    .on('error', console.error.bind(console))
    // autoprefix
    .pipe(autoprefixer({
      browsers: ['last 2 versions'],
      cascade: false
    }))
    // rename to .min
    // .pipe(rename(function(path) { path.basename += '.min'; }))
    .pipe(gulp.dest('css/'));
});

// BUILD PRODUCTION
gulp.task('copy_to_production', function() {
  // copy css files
  gulp.src('css/*.css')
    .pipe(concat('main.min.css'))
    .pipe(uglifyCss())
    .on('error', console.error.bind(console))
    .pipe(gulp.dest('build/css/'));
  // copy js files
  gulp.src('js/*.js')
    .pipe(concat('scripts.min.js'))
    .pipe(uglifyJs())
    .on('error', console.error.bind(console))
    .pipe(gulp.dest('build/js/'));
  // copy HTML files / inject static files
  gulp.src('./*.html')
  .pipe(gulp.dest('build/'));
});
// inject
gulp.task('inject_production', function() {
  gulp.src('build/*.html')
    .pipe(inject(gulp.src(['build/js/**/*.js', 'build/css/**/*.css'],{read: false}), {relative: true}))
    .pipe(gulp.dest('build/'));
});
// copy images
gulp.task('copy_img_to_production', function() {
  gulp.src('img/*')
    .pipe(gulp.dest('build/img/'));
});

// SERVER / WATCH TASK
// startes server, watches javascript, css
gulp.task('serve', function(){
  var server = gls.static('.', 8080);
  server.start();
  // watch css for changes
  gulp.watch(sassFiles, ['css']);
  // reloads the server
  gulp.watch(['js/*.js', 'css/*.css', './index.html'], function (file) {
    server.notify.apply(server, [file]);
  });
});

// run production tasks and production server
gulp.task('serve_production', function(){
  var server = gls.static('./build', 8080);
  server.start();
  // run css / js tasks
  gulp.watch(sassFiles, ['css']);
  gulp.watch(jsFiles, ['uglifyjs']);
  // reloads the server
  gulp.watch(['build/js/*.js', 'build/css/*.css', './index.html'], function (file) {
    server.notify.apply(server, [file]);
  });
});

gulp.task('test_production', ['copy_to_production', 'inject_production', 'serve_production']);
gulp.task('default', ['serve']);