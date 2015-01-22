'use strict';
var path = require('path');
var join = path.join;

var ctx;

exports.ctx = null;

ctx = exports.ctx;

var prompts = {
  initial: require('./prompts/initial')
};

var process = function process(cb) {
  var _this = this;
  function clojureProcess(results) {
    if(!results.correct) {

    }

    _this.format = results.format;

    _this.destPath = _this.destinationPath(join(
      'server/application/fixtures/',
      results.relpath,
      results.filename + '.' + _this.format
    ));

    _this.tplOptions = results;
    _this.tplPath = _this.templatePath('postgres/_postgres.' + _this.format);

    cb();
  }

  return clojureProcess;
};

exports.prompts = prompts.initial;
exports.process = process;


module.exports = exports;
