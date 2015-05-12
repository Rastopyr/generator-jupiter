'use strict';

var path = require('path');

var generators = require('yeoman-generator'),
    _ = require('underscore');

var prompt = function (path) {
  var _this = this, done = this.async();

  this.prompt(require(path), function (answers) {
    _.extend(_this.answers, answers);
    done();
  });
};

var tplFile = function (prefix, file, options) {
  this.fs.copyTpl(
    this.templatePath(path.join(prefix, file)),
    this.destinationPath(path.join(prefix, file)),
    options
  );
};

var copyDir = function (prefix, name) {
  this.directory(
    this.templatePath(path.join(prefix, name)),
    this.destinationPath(path.join(prefix, name))
  );
};

module.exports = generators.Base.extend({
  answers: {},

  propmtBaseConfig: function () {
    prompt.bind(this, './prompts/configs/base')();
  },

  propmtPostgresConfig: function () {
    prompt.bind(this, './prompts/configs/postgres')();
  },

  propmtRedisConfig: function () {
    prompt.bind(this, './prompts/configs/redis')();
  },

  templateConfigs: function () {
    var prefix = 'server/application/config/';

    tplFile.bind(this, prefix, 'postgres.coffee', this.answers)();
    tplFile.bind(this, prefix, 'redis.coffee', this.answers)();
    tplFile.bind(this, prefix, 'base.coffee', this.answers)();
    tplFile.bind(this, prefix, 'fixture.coffee', this.answers)();
    tplFile.bind(this, prefix, 'migration.coffee', this.answers)();

    tplFile.bind(this, prefix, 'routes/index.coffee');
    tplFile.bind(this, prefix, 'scopes/index.coffee');
    tplFile.bind(this, prefix, 'socket/index.coffee');
  },
  templateDockerCompose: function () {
    var prefix = '';

    tplFile.bind(this, prefix, 'docker-compose.yml', this.answers)();
    tplFile.bind(this, prefix, 'index.coffee', this.answers)();
    tplFile.bind(this, prefix, 'README.md', this.answers)();

    this.fs.copyTpl(
      this.templatePath(path.join(prefix, '_package.json')),
      this.destinationPath(path.join(prefix, 'package.json'))
    );

    // this.npmInstall();
  },

  templateApplication: function () {
    var prefix = 'server/application';

    copyDir.bind(this, prefix, 'controller')();
    copyDir.bind(this, prefix, 'fixtures')();
    copyDir.bind(this, prefix, 'lib')();
    copyDir.bind(this, prefix, 'loader')();
    copyDir.bind(this, prefix, 'model')();
    copyDir.bind(this, prefix, 'static')();
    copyDir.bind(this, prefix, 'utility')();
  },

  templateCore: function () {
    var prefix = 'server';

    copyDir.bind(this, prefix, 'core')();
    copyDir.bind(this, prefix, 'test')();
  }
});
