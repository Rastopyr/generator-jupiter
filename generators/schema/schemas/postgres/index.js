'use strict';
var path = require('path');

var yeoman = require('yeoman-generator');
var _ = require('yeoman-generator/node_modules/lodash');

var prompts = {
  initial: require('./prompts/initial'),
  options: require('./prompts/options'),
  fields: require('./prompts/fields'),
  assocs: require('./prompts/assocs')
};

module.exports = yeoman.generators.Base.extend({
  initializing: function () {
    this.fields = [];
    this.assocs = [];

    this.addAnyField = true;
    this.isAddAnyAssoc = true;
  },
  prompts: function () {
    var _this = this, done = this.async();

    this.prompt(prompts.initial, function (results) {
      if(!results.correct) {
        return _this.prompts();
      }

      _this.format = results.format;
      _this.filename = results.filename;
      _this.tplOptions = results;
      _this.tplOptions.name = results.schemaname;
      _this.relpath = results.relpath;

      _this.destPath = _this.destinationPath(path.join(
        'server/application/model/',
        results.relpath,
        results.filename + '.' + _this.format
      ));

      _this.tplPath = _this.templatePath(
        '../../../templates/postgres/_postgres.' + _this.format
      );

      done();
    });
  },
  isAddAnyField: function() {
    var _this = this, done = this.async();

    this.prompt([{
        name: 'addnew',
        type: 'confirm',
        message: 'Add new field to Schema?',
        default: true
    }], function (result) {
      if(!result.addnew) {
        _this.addAnyField = false;
      }

      done();
    });
  },
  addField: function () {
    var _this = this, done;

    if(!this.addAnyField) {
      return;
    }

    done = this.async();

    this.prompt(prompts.fields, function (results) {
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
  options: function () {
    var _this = this, done = this.async();

    this.prompt(prompts.options, function (results) {
      if (!results.correct) {
        return _this.options();
      }

      _this.tplOptions.options = results;

      done();
    });
  },
  isAddAnyAssoc: function () {
    var _this = this, done = this.async();

    this.prompt([{
        name: 'addnew',
        type: 'confirm',
        message: 'Add new association to Schema?',
        default: true
    }], function (result) {
       if(!result.addnew) {
          _this.isAddAnyAssoc = false;
        }

        done();
    });
  },
  addAssoc: function () {
    var _this = this, done;

    if(!this.isAddAnyAssoc) {
      return;
    }

    done = this.async();

    this.prompt(prompts.assocs, function (results) {
      if (!results.correct) {
        if (results.again) {
          return _this.addAssoc();
        }
      }

      _this.assocs.push(results);

      if (results.again) {
        return _this.addAssoc();
      }

      done();
    });
  },
  write: function() {
    this.tplOptions = _.extend(this.tplOptions, {
      fields: this.fields,
      assocs: this.assocs
    });

    this.fs.copyTpl(this.tplPath, this.destPath, this.tplOptions);
  }
});
