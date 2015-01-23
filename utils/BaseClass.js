'use strict';

var util = require('util');
var path = require('path');
var fs = require('fs');

var yeoman = require('yeoman-generator');
var yosay = require('yosay');
var chalk = require('chalk');
var _ = require('yeoman-generator/node_modules/lodash');

var inflection = require('underscore.inflection');

/*
  Mixin plural logick to lodash
 */

_.mixin(inflection.resetInflections());

/*
  Expose `BaseClass`
 */

module.exports = {
  initializing: function (args) {;
    var entities, _this = this;

    this.entities = [];

    this.singular = _.singularize(this.entity);
    this.plural = _.pluralize(this.entity);

    this.Plural = _.capitalize(this.plural);
    this.Singular = _.capitalize(this.singular);

    this.log(yosay(
      'Welcome to the ' + chalk.green('Jupiter'+this.Plural) + ' generator!'
    ));

    entities = fs.readdirSync(path.join(this.rootPath, this.plural));

    _.map(entities, function (entity) {
      _this.entities.push(_.capitalize(path.basename(entity, path.extname(entity))));
    });
  },
  prompts: function() {
    this.async();

    this.prompt({
      name: 'type',
      type: 'list',
      message: 'Select your '+this.singular+' type',
      choices: this.entities
    }, process.bind(this));
  }
};

function process(results) {
  var ns, fp, done;

  done = this.async();

  this.type = results.type.toLowerCase();

  fp = path.join(this.rootPath, this.plural, this.type);
  ns = this.env.namespace(fp);
  this.env.register(fp, ns);

  // this.adapter = require(path.join(__dirname, this.plural, this.type));

  this.composeWith(ns, {
    options: results,
    arguments: []
  });

  done();
}
