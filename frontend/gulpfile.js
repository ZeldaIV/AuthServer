var gulp = require('gulp');
var elm = require('gulp-elm');
var plumber = require('gulp-plumber');
const gulpServerIo = require('gulp-server-io');
//var connect = require('gulp-connect');

var paths = {
    dest: '../wwwroot',
    elm: 'src/Main.elm',
    static: '*.{html,css}'
};

// Compile Elm to HTML
gulp.task('elm', function(){
    return gulp.src(paths.elm)
        .pipe(plumber())
        .pipe(elm())
        .pipe(gulp.dest(paths.dest));
});

// Move static assets to dist
gulp.task('static', function() {
    return gulp.src(paths.static)
        .pipe(plumber())
        .pipe(gulp.dest(paths.dest));
});

// Watch for changes and compile
gulp.task('watch:all', function() {
    gulp.watch(paths.elm, gulp.series('build'))
    gulp.watch(paths.static, gulp.series('static'))
});

gulp.task('serve', () => {
    return gulp.src(paths.dest)
        .pipe(
            gulpServerIo({
                webroot: paths.dest,
                host: "127.0.0.1",
                https: true
            })
        );
});


// Main gulp tasks
gulp.task('build', gulp.series('elm', 'static'));
gulp.task('default', gulp.series('build', 'serve'));
gulp.task('watch', gulp.parallel('serve', 'watch:all'))
