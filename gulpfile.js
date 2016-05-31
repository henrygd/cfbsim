var gulp = require('gulp'),
    uglifyJs = require('gulp-uglify'),
    rename = require('gulp-rename'),
    gls = require('gulp-live-server'),
    sass = require('gulp-sass'),
    ghPages = require('gulp-gh-pages'),
    concat = require('gulp-concat'),
    inject = require('gulp-inject'),
    postcss = require('gulp-postcss'),
    autoprefixer = require('autoprefixer'),
    mqpacker = require('css-mqpacker'),
    csswring = require('csswring');

var sassFiles = ['css/**/*.scss'];
var jsFiles = ['js/*.js'];

// GITHUB GH-PAGES DEPLOY
gulp.task('deploy', function() {
  return gulp.src('./build/**/*')
    .pipe(ghPages());
});

// INJECT STATIC FILE LINKS INTO HTML (DEV)
gulp.task('inject', function () {
  var target = gulp.src('./index.html');
  var sources = gulp.src(['js/*.js', 'css/**/*.css'], {read: false});
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
  var processors = [
    autoprefixer({browsers: ['last 2 versions']}),
    mqpacker,
    csswring
  ];
  gulp.src(sassFiles)
    // convert sass to css
    .pipe(sass().on('error', sass.logError))
    // minify / prefix
    .pipe(postcss(processors))
    // save
    .pipe(gulp.dest('css/'));
});


//////// BUILD PRODUCTION ////////
// COPY HTML
gulp.task('copy_html_to_production', function() {
  return gulp.src('./*.html')
    .pipe(gulp.dest('./build'));
})
// CONCAT / MINIFY / COPY CSS
gulp.task('copy_css_to_production', ['copy_html_to_production'], function() {
  var processors = [
    autoprefixer({browsers: ['last 2 versions']}),
    mqpacker,
    csswring
  ];
  return gulp.src('css/*.css')
    .pipe(concat('main.min.css'))
    // minify / prefix
    .pipe(postcss(processors))
    .pipe(gulp.dest('build/css/'));
})
// CONCAT / MINIFY / COPY JAVASCRIPT
gulp.task('copy_js_to_production', ['copy_css_to_production'], function() {
  gulp.src('js/*/*.js')
    .pipe(gulp.dest('build/js/'));
  return gulp.src('js/*.js')
    .pipe(concat('scripts.min.js'))
    .pipe(uglifyJs())
    .on('error', console.error.bind(console))
    .pipe(gulp.dest('build/js/'));
})
// INJECT SCRIPTS INTO HTML
gulp.task('inject_production', ['copy_js_to_production'], function() {
  return gulp.src('./build/*.html')
    .pipe(inject(gulp.src(['./build/js/*.js', './build/css/*.css'],{read: false}), {relative: true}))
    .pipe(gulp.dest('./build'));
});
// COPY IMAGES
gulp.task('copy_img_to_production', ['inject_production'], function() {
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
});

gulp.task('default', ['serve']);
gulp.task('build_production', 
  [
    'copy_html_to_production', 
    'copy_css_to_production', 
    'copy_js_to_production', 
    'inject_production',
    'copy_img_to_production'
  ]
);