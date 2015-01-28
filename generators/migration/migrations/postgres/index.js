'use strict';
var path = require('path');

var yeoman = require('yeoman-generator');
var _ = require('yeoman-generator/node_modules/lodash');

var prompts = {
  initial: require('./prompts/initial'),
  actions: require('./prompts/actions')
};

module.exports = yeoman.generators.Base.extend({
  initializing: function () {
    this.addSomeField = true;
  },
  prompts: function () {
    var _this = this, done = this.async();

    this.prompt(prompts.initial, function (results) {
      if (!results.correct) {
        return _this.prompts();
      }

      _this.options = _.extend(_this.options, results);

      _this.destPath = _this.destinationPath(path.join(
        'server/application/migration/',
        results.relpath,
        results.filename + '.' + results.format
      ));

      _this.tplPath = _this.templatePath(
        '../../../templates/postgres/_postgres.' + results.format
      );

      done();
    });
  },
  chooseCommand: function () {
    var _this = this, done = this.async();

    this.prompt(prompts.actions, function (results) {
      _this.options = _.extend(_this.options, results);

      done();
    });
  },
  startTypeGenerator: function () {
    var pathToType, type = this.options.actionup, ns;

    pathToType = path.join(__dirname, 'types', type);

    ns = this.env.namespace(pathToType);

    this.env.register(pathToType, ns);

    this.composeWith(ns, {
      options: this.options,
      arguments: []
    });
  }
});
