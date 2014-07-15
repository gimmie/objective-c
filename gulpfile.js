var fs = require('fs-extra')
  , git = require('gift')
  , github = require('github')
  , wrench = require('wrench')
  , cp = wrench.copyDirSyncRecursive
  , mkdir = fs.mkdirs
  , rm = fs.remove
  , gulp = require('gulp')
  , path = require('path')
  , q = require('q')
  , zip = require('gulp-zip')
  , xcodebuild = require('xcodebuild')

var BUILD_DIR = path.join(process.cwd(), 'build')
  , BUILD_LIB = path.join(BUILD_DIR, 'Release-universal')
  , RELEASE_DIR = path.join(BUILD_DIR, 'gimmie')
  , HEADER_DIR = path.join(RELEASE_DIR, 'include')
  , SRC_DIR = path.join(process.cwd(), 'API')

gulp.task('clean', function (done) {
  q.nfcall(xcodebuild, 'clean')
    .then(q.nfcall(rm, BUILD_DIR))
    .done(done)
})

gulp.task('build', ['clean'], function (done) {
  q.nfcall(xcodebuild, 'archive', {
    scheme: 'GimmieAPI',
    configuration: 'Release'
  })
  .then(function () {
    console.log ('Copy all resources to archive dir')

    cp(BUILD_LIB, RELEASE_DIR)
    mkdir(HEADER_DIR)

    // Search all header files first
    var headers = []
    var queue = [ SRC_DIR ]
    while (queue.length > 0) {
      var first = queue.shift()

      var files = fs.readdirSync(first)
      files.forEach(function (file) {
        var fullpath = path.join(first, file)
        if (fs.statSync(fullpath).isDirectory()) {
          queue.push(fullpath)
        }
        else if (/^.*\.h$/.test(file)) {
          headers.push(fullpath)
        }
      })
    }

    // Copy all headers to release folder
    headers.forEach(function (header) {
      var from = header, to = path.join(HEADER_DIR, path.basename(header))
      fs.writeFileSync(to, fs.readFileSync(from))
    })

    return
  })
  .done(done)
})

gulp.task('archive', [ 'build' ], function () {
  console.log (RELEASE_DIR)
  return gulp.src(path.join(RELEASE_DIR, '**', '*'))
    .pipe(zip('gimmie.zip'))
    .pipe(gulp.dest(BUILD_DIR))
})

gulp.task('default', [ 'build' ])
