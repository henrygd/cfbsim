var gulp = require('gulp'),
    uglifyJs = require('gulp-uglify'),
    uglifyCss = require('gulp-uglifycss'),
    // rename = require('gulp-rename'),
    autoprefixer = require('gulp-autoprefixer'),
    gls = require('gulp-live-server'),
    ghPages = require('gulp-gh-pages'),
    sass = require('gulp-ruby-sass'),
    concat = require('gulp-concat');


// SCRIPTS TASKS
// uglifies javascript
// gulp.task('scripts', function(){
//   gulp.src('js/*.js')
//     .pipe(uglifyJs())
//     .on('error', console.error.bind(console))
//     // rename to .min
//     .pipe(rename(function(path) { path.basename += '.min'; }))
//     .pipe(gulp.dest('build/js/'));
//     // .pipe(gulp.dest('../bigimg/'));
//     // .pipe(livereload());
// });

gulp.task('scripts', function() {
  return gulp.src('./js/*.js')
    .pipe(concat('scripts.js'))
    .pipe(uglifyJs())
    .on('error', console.error.bind(console))
    .pipe(gulp.dest('./build/js/'));
});

// STYLE TASKS
// prefixes / uglifies css
// gulp.task('css', function(){
//   gulp.src('css/*.css')
//     .pipe(concat('main.min.css'))
//     // uglify
//     .pipe(uglifyCss())
//     // prefix
//     .pipe(autoprefixer({
//       browsers: ['last 2 versions'],
//       cascade: false
//     }))
//     .pipe(gulp.dest('build/css/'));
// });

// SASS
gulp.task('sass', function () {
  return sass('css/*.scss')
    .on('error', sass.logError)
    .pipe(gulp.dest('css/'));
});

// HTML TASKS
gulp.task('html', function(){
  gulp.src('*.html')
    .pipe(gulp.dest('../bigimg/'));
});

// IMAGE TASK
// compresses images
// gulp.task('image', function(){
//   gulp.src('images/*')
//     .pipe( imagemin() )
//     .pipe( gulp.dest('build/img/'));
// });

// WATCH TASK
// watches javascript, css
gulp.task('serve', function(){
  var server = gls.static('.', 8080); //equals to gls.static('public', 3000); 
  server.start();
  // gulp.watch('js/*.js', ['scripts']);
  // watch css for changes
  gulp.watch('css/*.scss', ['sass']);
  // reloads the server
  gulp.watch(['js/*.js', 'css/*.css', '*.html'], function (file) {
    server.notify.apply(server, [file]);
  });
});

gulp.task('default', ['scripts', 'css', 'html', 'serve']);