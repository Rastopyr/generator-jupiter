'use strict';
var util = require('util');
var path = require('path');
var join = path.join;

var yeoman = require('yeoman-generator');
var chalk = require('chalk');
var yosay = require('yosay');
var _ = require('yeoman-generator/node_modules/lodash');

var async = require('async');

var fields = [], assocs = [];

var prompts = {
  options: require('./prompts/options'),
  fields: require('./prompts/fields'),
  assocs: require('./prompts/assocs')
};

var processFieldResponse = function (field) {
  fields.push(field);
};

var processAssocResponse = function (assoc) {
  assocs.push(assoc);
  console.log(assocs.length);
};

var processFields = function (callback) {
  var _this = this;

  this.prompt(prompts.fields, function (results) {
    if (!results.correct) {
      if (results.again) {
        return processFields.bind(_this)(callback);
      }
    }

    processFieldResponse.bind(_this)(results);

    if (results.again) {
      return processFields.bind(_this)(callback);
    }

    callback(null, fields);
  });
};

var processOptions = function (callback) {
  var _this = this;

  this.prompt(prompts.options, function (results) {
    if (!results.correct) {
      return processOptions.bind(_this)(callback);
    }

    callback(null, results);
  });
};

var processAssocs = function (callback) {
  var _this = this;

  this.prompt(prompts.assocs, function (results) {
    if (!results.correct) {
      if (results.again) {
        return processAssocs.bind(_this)(callback);
      }
    }

    processAssocResponse.bind(_this)(results);

    if (results.again) {
      return processAssocs.bind(_this)(callback);
    }

    callback(null, assocs);
  });
};

var processResponse = function (results) {
  if (!results.correct) {
    return processResponse.bind(this)(results);
  }

  var _this = this, done = this.async();

  this.format = results.format;

  this.destPath = join(
    'server/application/model/',
    results.relpath,
    results.filename + '.' + _this.format
  );

  async.series({
    fields: processFields.bind(this),
    options: processOptions.bind(this),
    assocs: processAssocs.bind(this)
  }, function (err, resp) {
    if (err) {
      throw err;
    }

    results = _.extend({
      name: results.schemaname,
      filename: results.filename
    }, resp);

    _this.tplOptions = results;
    _this.tplPath = _this.templatePath('postgres/_postgres.' + _this.format);
    _this.destPath = _this.destinationPath(_this.destPath);

    done();
  });
};

exports.processResponse = processResponse;

exports.prompts = [
  {
    name: 'format',
    type: 'list',
    message: 'Select fromat of schema file',
    choices: [
      'coffee', 'js'
    ]
  },
  {
    name: 'schemaname',
    type: 'input',
    message: 'Type name of your Schema',
    store   : true,
    default: 'schema-' + (new Date()).getTime()
  },
  {
    name: 'relpath',
    type: 'input',
    message: 'Relative path, where Schema will be created&',
    store   : true,
    default: ''
  }, {
    name: 'filename',
    type: 'input',
    message: 'Type filename of your Schema',
    store   : true,
    default: 'schema-' + (new Date()).getTime()
  }, {
    name: 'correct',
    type: 'confirm',
    message: 'Name is correct? We can go to specify fields?',
    default: true
  }
];

module.exports = exports;
