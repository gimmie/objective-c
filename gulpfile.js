var fs = require('fs-extra')
  , gulp = require('gulp')
  , path = require('path')
  , q = require('q')
  , rm = fs.remove
  , xcodebuild = require('xcodebuild')

var BUILD_DIR = path.join(process.cwd(), 'build')

gulp.task('clean', function (done) {
  q.nfcall(xcodebuild, 'clean')
    .then(q.nfcall(rm, BUILD_DIR))
    .done(done)
})

gulp.task('build', ['clean'], function () {
  q.nfcall(xcodebuild, 'build', {
    scheme: 'GimmieAPI',
    configuration: 'Release'
  }).done(done)
})

gulp.task('default', [ 'build' ])
