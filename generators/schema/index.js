'use strict';
var fs = require('fs');
var path = require('path');
var join = path.join;

var yeoman = require('yeoman-generator');
var chalk = require('chalk');
var yosay = require('yosay');
var _ = require('yeoman-generator/node_modules/lodash');
var RunContext = require('yeoman-generator/lib/test/run-context');
var async = require('async');

function getSchemaTypes() {
  var schemas = fs.readdirSync(join(__dirname, 'schemas'));

  return _.map(schemas, function (schema) {
    return _.capitalize(path.basename(schema, path.extname(schema)));
  });
}

function processResponse(results) {
  var filePath;

  this.type = this.type || results.type.toLowerCase();
  this.format = results.format;

  filePath = join(__dirname, 'schemas', this.type);

  this.adapter = require(filePath);

  this.prompt(
    this.adapter.prompts,
    this.adapter.processResponse.bind(this)
  );
}

module.exports = yeoman.generators.Base.extend({
  fields: {},
  initializing: function () {
    this.pkg = require('../../package.json');
  },
  prompting: function () {
    var schemas, prompts;

    var done = this.async();

    this.log(yosay(
      'Welcome to the ' + chalk.green('JupiterSchema') + ' generator!'
    ));

    schemas = getSchemaTypes();

    prompts = [{
      name: 'type',
      type: 'list',
      message: 'Select your schema type',
      choices: schemas
    }];

    this.prompt(prompts, processResponse.bind(this));
  },
  writing: function() {
    // console.log('fireWriting');
    this.fs.copyTpl(this.tplPath, this.destPath, this.tplOptions);
  }
});
