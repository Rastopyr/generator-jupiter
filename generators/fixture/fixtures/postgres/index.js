'use strict';
var path = require('path');

var yeoman = require('yeoman-generator');

var prompts = {
  initial: require('./prompts/initial')
};

module.exports = yeoman.generators.Base.extend({
  prompts: function () {
    var _this = this, done = this.async();

    this.prompt(prompts.initial, function (results) {
      if (!results.correct) {
        return _this.prompts();
      }

      _this.tplOptions = results;
      _this.format = results.format;
      _this.relpath = results.relpath;
      _this.filename = results.filename;

      done();
    });
  },
  paths: function () {
    this.destPath = this.destinationPath(path.join(
      'server/application/fixtures/',
      this.relpath,
      this.filename + '.' + this.format
    ));

    this.tplPath = this.templatePath('../../../templates/postgres/_postgres.' + this.format);
  },
  write: function () {
    this.fs.copyTpl(
      this.tplPath,
      this.destPath,
      this.tplOptions
    );
  }
});
