'use strict';
var path = require('path');

var yeoman = require('yeoman-generator');
var _ = require('yeoman-generator/node_modules/lodash');

module.exports = yeoman.generators.Base.extend({
  initializing: function () {
    var prompts;

    prompts = require('../prompts/types/createTable');

    this.options.actionup = 'createTable';
    this.options.actiondown = 'dropTable';

    this.options.fields = this.env.store.get('fields') || [];

    this.addAnyField = true;
    this.fields = this.options.fields;

    this.questions = {
      table: prompts.table,
      fields: prompts.fields,
      options: prompts.options
    };
  },
  prompts: function () {
    var _this = this, done = this.async();

    this.prompt(this.questions.table, function (results) {
      _this.options = _.extend(_this.options, results);

      done();
    });
  },
  isAddAnyField: function () {
    var _this = this, done = this.async();

    this.prompt([{
      name: 'addnew',
      type: 'confirm',
      message: 'Add new field to Migration?',
      default: true
    }], function (result) {
      if (!result.addnew) {
        _this.addAnyField = false;
      }

      done();
    });
  },
  addField: function () {
    var _this = this, done;

    if (!this.addAnyField) {
      return;
    }

    done = this.async();

    this.prompt(this.questions.fields, function (results) {
      if (!results.correct) {
        if (results.again) {
          return _this.addField();
        }
      }

      _this.fields.push(results);

      if (results.again) {
        return _this.addField();
      }

      done();
    });
  },
  tableOptions: function() {
    var _this = this, done = this.async();

    this.prompt(this.questions.options, function (results) {
      _this.options = _.extend(_this.options, results);

      done();
    });
  },
  writing: function () {
    var destPath, tplPath;

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
