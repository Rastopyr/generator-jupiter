'use strict';
var yeoman = require('yeoman-generator');
var _ = require('yeoman-generator/node_modules/lodash');

var Base = require('../../utils/BaseClass');

var Class = _.extend({
  entity: 'fixtures',
  rootPath: __dirname
}, Base);

module.exports = yeoman.generators.Base.extend(Class);
