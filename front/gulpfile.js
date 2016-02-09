var gulp = require('gulp');
var $ = require('gulp-load-plugins')();

var paths = {
    jade: 'partials/*.jade',
    coffee: 'coffee/*.coffee',
    dist: 'dist/'
};

gulp.task('copy-config', function() {
    return gulp.src('slack.json')
        .pipe(gulp.dest(paths.dist));
});

gulp.task('jade', function() {
    return gulp.src(paths.jade)
        .pipe($.plumber())
        .pipe($.jade({pretty: true}))
        .pipe(gulp.dest(paths.dist));
});

gulp.task('coffee', function() {
    return gulp.src(paths.coffee)
        .pipe($.plumber())
        .pipe($.coffee())
        .pipe(gulp.dest(paths.dist));
});

gulp.task('watch', function() {
    gulp.watch(paths.jade, ['jade']);
    gulp.watch(paths.coffee, ['coffee']);
});

gulp.task('default', [
    'copy-config',
    'coffee',
    'jade',
    'watch'
]);
