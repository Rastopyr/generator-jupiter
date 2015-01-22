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

function getFixtureTypes() {
  var schemas = fs.readdirSync(join(__dirname, 'fixtures'));

  return _.map(schemas, function (schema) {
    return _.capitalize(path.basename(schema, path.extname(schema)));
  });
}

function process(results) {
  var filePath;

  this.type = this.type || results.type.toLowerCase();

  filePath = join(__dirname, 'fixtures', this.type);

  this.adapter = require(filePath);

  this.prompt(
    this.adapter.prompts,
    this.adapter.process.bind(this)(this.async())
  );
}

module.exports = yeoman.generators.Base.extend({
  initializing: function () {
    this.pkg = require('../../package.json');
  },
  prompting: function () {
    var fixtures;

    this.async();

    this.log(yosay(
      'Welcome to the ' + chalk.green('JupiterFixture') + ' generator!'
    ));

    fixtures = getFixtureTypes();

    this.prompt([{
      name: 'type',
      type: 'list',
      message: 'Select your fixture type',
      choices: fixtures
    }], process.bind(this));
  },
  writing: function () {
    this.fs.copyTpl(this.tplPath, this.destPath, this.tplOptions);
  }
});
