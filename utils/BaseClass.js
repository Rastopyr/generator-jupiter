'use strict';

var path = require('path');
var fs = require('fs');

var yosay = require('yosay');
var chalk = require('chalk');
var _ = require('yeoman-generator/node_modules/lodash');

var inflection = require('underscore.inflection');

/*
  Mixin plural logick to lodash
 */

_.mixin(inflection.resetInflections());

/*
  Process prompts of types
 */
function process(results) {
  var ns, fp, done;

  // callback
  done = this.async();

  // Save name of Subgenerator
  this.type = results.type.toLowerCase();

  // Generate namespace
  fp = path.join(this.rootPath, this.plural, this.type);
  ns = this.env.namespace(fp);

  // Register subgenerator
  this.env.register(fp, ns);

  // Start subgenerator
  this.composeWith(ns, {
    options: results,
    arguments: []
  });

  done();
}


/*
  Expose `BaseClass`
 */

module.exports = {
  initializing: function () {
    var entities, _this = this;

    this.entities = [];

    this.singular = _.singularize(this.entity);
    this.plural = _.pluralize(this.entity);

    this.Plural = _.capitalize(this.plural);
    this.Singular = _.capitalize(this.singular);

    this.log(yosay(
      'Welcome to the ' + chalk.green('Jupiter' + this.Plural) + ' generator!'
    ));

    entities = fs.readdirSync(path.join(this.rootPath, this.plural));

    _.map(entities, function (entity) {
      _this.entities.push(_.capitalize(path.basename(entity, path.extname(entity))));
    });
  },
  prompts: function () {
    this.async();

    this.prompt({
      name: 'type',
      type: 'list',
      message: 'Select your ' + this.singular + ' type',
      choices: this.entities
    }, process.bind(this));
  }
};
