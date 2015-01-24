'use strict';
var path = require('path');

var yeoman = require('yeoman-generator');
var _ = require('yeoman-generator/node_modules/lodash');

module.exports = yeoman.generators.Base.extend({
  initializing: function () {
    this.options.actionup = 'dropTable';
  },
  prompts: function () {
    var _this = this, done = this.async();

    this.prompt(require('../prompts/types/dropTable'), function (results) {
      _this.options = _.extend(_this.options, results);

      done();
    });
  },
  writing: function () {
    var destPath, tplPath;

    this.options.fields = this.fields;

    destPath = this.destinationPath(path.join(
      'server/application/migration',
      this.options.relpath,
      this.options.filename + '.' + this.options.format
    ));

    tplPath = this.templatePath(path.join(
      '../../../../',
      'templates/postgres',
      this.options.format,
      'types',
      '_' + this.options.actionup + '.' + this.options.format
    ));

    this.fs.copyTpl(tplPath, destPath, this.options);
  }
});
