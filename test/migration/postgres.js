/*globals it, describe, before */
'use strict';

var path = require('path');
var events = require('events');

var assert = require('yeoman-generator').assert;
var helpers = require('yeoman-generator').test;
var os = require('os');
var _ = require('yeoman-generator/node_modules/lodash');
var async = require('async');

describe('jupiter:migration', function () {
  describe('postgres', function () {
    describe('with coffee', function () {
      var options, tmpDir, fixture;

      options = {
        addColumn: {
          table: 'table-' + (new Date()).getTime(),
          column: 'column-' + (new Date()).getTime(),
          dataType: 'BOOLEAN',
        },
        changeColumn: {
          table: 'table-' + (new Date()).getTime(),
          column: 'column-' + (new Date()).getTime(),
          dataType: 'TEXT'
        },
        renameColumn: {
          table: 'table-' + (new Date()).getTime(),
          attrNameBefore: 'column-' + (new Date()).getTime(),
          attrNameAfter: 'column-' + (new Date()).getTime()
        },
        removeColumn: {
          table: 'table-' + (new Date()).getTime(),
          column: 'column-' + (new Date()).getTime(),
          dataType: 'BIGINT'
        },
        addIndex: {
          table: 'table-' + (new Date()).getTime(),
          columns: 'firstname,lastname'
        },
        removeIndex: {
          table: 'table-' + (new Date()).getTime(),
          columns: 'firstname,lastname'
        },
        createTable: {
          table: 'table-' + (new Date()).getTime(),
          addnew: false,
          chooseengine: true,
          enginename: 'MYISAM'
        },
        dropTable: {
          table: 'table-' + (new Date()).getTime()
        }
      };

      tmpDir = path.join(os.tmpdir(), './temp-test');

      fixture = {
        type: 'Postgres',
        format: 'coffee',
        relpath: 'relpath'
      };

      function generatorStart(action, callback) {
        var prompts, filename;

        filename = 'migration-' + (new Date()).getTime();
        options[action].filename = filename;
        fixture.actionup = action;

        prompts = _.extend(fixture, options[action]);

        var runner = helpers.run(path.join(__dirname, '../../generators/migration/index.js'))
          .inDir(tmpDir)
          .withPrompt(prompts);

        runner.on('end', callback);
      }

      function generatedPath(action) {
        return path.join(
          'server/application/migration/',
          fixture.relpath,
          options[action].filename + '.' + fixture.format
        );
      }

      describe('addColumn', function () {
        var action = 'addColumn', path;

        before(function (done) {
          generatorStart(action, function (err) {
            if (err) {
              return done(err);
            }

            path = generatedPath(action);
            done();
          });
        });

        it('create files', function () {
          assert.file(path);
        });

        it('file content', function () {
          helpers.assertFileContent(path, /up = \(migration\, DataTypes\, done\) \-\>/);

          helpers.assertFileContent(path, /migration\.addColumn\(\n/);
          helpers.assertFileContent(path, new RegExp('"' + options[action].table + '",'));
          helpers.assertFileContent(path, new RegExp('"' + options[action].column + '",'));
          helpers.assertFileContent(path, new RegExp('DataTypes.' + options[action].dataType));
          helpers.assertFileContent(path, /\)\.done\(done\)/);

          helpers.assertFileContent(path, /down = \(migration\, DataTypes\, done\) \-\>/);
          helpers.assertFileContent(path, /migration\.removeColumn\(\n/);
          helpers.assertFileContent(path, new RegExp('"' + options[action].table + '",'));
          helpers.assertFileContent(path, new RegExp('"' + options[action].column + '",'));
          helpers.assertFileContent(path, /\)\.done\(done\)/);

          helpers.assertFileContent(path, /exports = \{\n {2}up\n {2}down\n\}/);
          helpers.assertFileContent(path, /module\.exports = exports/);
        });
      });

      describe('changeColumn', function () {
        var action = 'changeColumn', path;

        before(function (done) {
          generatorStart(action, function (err) {
            if (err) {
              return done(err);
            }

            path = generatedPath(action);
            done();
          });
        });

        it('create files', function () {
          assert.file(path);
        });

        it('file content', function () {
          helpers.assertFileContent(path, /up = \(migration\, DataTypes\, done\) \-\>/);

          helpers.assertFileContent(path, /migration\.changeColumn\(\n/);
          helpers.assertFileContent(path, new RegExp('"' + options[action].table + '",'));
          helpers.assertFileContent(path, new RegExp('"' + options[action].column + '",'));
          helpers.assertFileContent(path, new RegExp('DataTypes.' + options[action].dataType));
          helpers.assertFileContent(path, /\)\.done\(done\)/);

          helpers.assertFileContent(path, /down = \(migration\, DataTypes\, done\) \-\>/);
          helpers.assertFileContent(path, /done()/);

          helpers.assertFileContent(path, /exports = \{\n {2}up\n {2}down\n\}/);
          helpers.assertFileContent(path, /module\.exports = exports/);
        });
      });

      describe('renameColumn', function () {
        var action = 'renameColumn', path;

        before(function (done) {
          generatorStart(action, function (err) {
            if (err) {
              return done(err);
            }

            path = generatedPath(action);
            done();
          });
        });

        it('create files', function () {
          assert.file(path);
        });

        it('file content', function () {
          helpers.assertFileContent(path, /up = \(migration\, DataTypes\, done\) \-\>/);
          helpers.assertFileContent(path, /migration\.renameColumn\(\n/);
          helpers.assertFileContent(path, new RegExp('"' + options[action].attrNameBefore + '",'));
          helpers.assertFileContent(path, new RegExp('"' + options[action].attrNameAfter + '",'));
          helpers.assertFileContent(path, /\)\.done\(done\)/);

          helpers.assertFileContent(path, /down = \(migration\, DataTypes\, done\) \-\>/);
          helpers.assertFileContent(path, /migration\.renameColumn\(\n/);
          helpers.assertFileContent(path, new RegExp('"' + options[action].attrNameAfter + '",'));
          helpers.assertFileContent(path, new RegExp('"' + options[action].attrNameBefore + '",'));
          helpers.assertFileContent(path, /\.done\(done\)/);

          helpers.assertFileContent(path, /exports = \{\n {2}up\n {2}down\n\}/);
          helpers.assertFileContent(path, /module\.exports = exports/);
        });
      });

      describe('removeColumn', function () {
        var action = 'removeColumn', path;

        before(function (done) {
          generatorStart(action, function (err) {
            if (err) {
              return done(err);
            }

            path = generatedPath(action);
            done();
          });
        });

        it('create files', function () {
          assert.file(path);
        });

        it('file content', function () {
          helpers.assertFileContent(path, /up = \(migration\, DataTypes\, done\) \-\>/);
          helpers.assertFileContent(path, /migration\.removeColumn\(\n/);
          helpers.assertFileContent(path, new RegExp('"' + options[action].table + '",'));
          helpers.assertFileContent(path, new RegExp('"' + options[action].column + '",'));
          helpers.assertFileContent(path, /\)\.done\(done\)/);

          helpers.assertFileContent(path, /down = \(migration\, DataTypes\, done\) \-\>/);
          helpers.assertFileContent(path, /migration\.addColumn\(\n/);
          helpers.assertFileContent(path, new RegExp('"' + options[action].table + '",'));
          helpers.assertFileContent(path, new RegExp('"' + options[action].column + '",'));
          helpers.assertFileContent(path, new RegExp('DataTypes.' + options[action].dataType));
          helpers.assertFileContent(path, /\)\.done\(done\)/);

          helpers.assertFileContent(path, /exports = \{\n {2}up\n {2}down\n\}/);
          helpers.assertFileContent(path, /module\.exports = exports/);
        });
      });

      describe('addIndex', function () {
        var action = 'addIndex', path;

        before(function (done) {
          generatorStart(action, function (err) {
            if (err) {
              return done(err);
            }

            path = generatedPath(action);
            done();
          });
        });

        it('create files', function () {
          assert.file(path);
        });

        it('file content', function () {
          var indexes = '';

          _.each(options[action].columns.split(','), function (string, key, list) {
            indexes += string.trim();

            if (key !== list.length - 1) {
              indexes += ', ';
            }
          });


          helpers.assertFileContent(path, /up = \(migration\, DataTypes\, done\) \-\>/);
          helpers.assertFileContent(path, /migration\.addIndex\(\n/);
          helpers.assertFileContent(path, new RegExp('"' + options[action].table + '",'));
          helpers.assertFileContent(path, new RegExp('[' + indexes + '],'));
          helpers.assertFileContent(path, /\)\.done()/);

          helpers.assertFileContent(path, /down = \(migration\, DataTypes\, done\) \-\>/);
          helpers.assertFileContent(path, /migration\.removeIndex\(\n/);
          helpers.assertFileContent(path, new RegExp('"' + options[action].table + '",'));
          helpers.assertFileContent(path, new RegExp('[' + indexes + '],'));
          helpers.assertFileContent(path, /\)\.done()/);

          helpers.assertFileContent(path, /exports = \{\n {2}up\n {2}down\n\}/);
          helpers.assertFileContent(path, /module\.exports = exports/);
        });
      });

      describe('removeIndex', function () {
        var action = 'removeIndex', path;

        before(function (done) {
          generatorStart(action, function (err) {
            if (err) {
              return done(err);
            }

            path = generatedPath(action);
            done();
          });
        });

        it('create files', function () {
          assert.file(path);
        });

        it('file content', function () {
          var indexes = '';

          _.each(options[action].columns.split(','), function (string, key, list) {
            indexes += string.trim();

            if (key !== list.length - 1) {
              indexes += ', ';
            }
          });


          helpers.assertFileContent(path, /up = \(migration\, DataTypes\, done\) \-\>/);
          helpers.assertFileContent(path, /migration\.removeIndex\(\n/);
          helpers.assertFileContent(path, new RegExp('"' + options[action].table + '",'));
          helpers.assertFileContent(path, new RegExp('[' + indexes + '],'));
          helpers.assertFileContent(path, /\)\.done()/);

          helpers.assertFileContent(path, /down = \(migration\, DataTypes\, done\) \-\>/);
          helpers.assertFileContent(path, /migration\.addIndex\(\n/);
          helpers.assertFileContent(path, new RegExp('"' + options[action].table + '",'));
          helpers.assertFileContent(path, new RegExp('[' + indexes + '],'));
          helpers.assertFileContent(path, /\)\.done()/);

          helpers.assertFileContent(path, /exports = \{\n {2}up\n {2}down\n\}/);
          helpers.assertFileContent(path, /module\.exports = exports/);
        });
      });

      describe('createTable', function () {
        var action = 'createTable', path;

        before(function (done) {
          generatorStart(action, function (err) {
            if (err) {
              return done(err);
            }

            path = generatedPath(action);
            done();
          });
        });

        it('create files', function () {
          assert.file(path);
        });

        it('file content', function () {
          helpers.assertFileContent(path, /up = \(migration\, DataTypes\, done\) \-\>/);
          helpers.assertFileContent(path, /migration\.createTable\(\n/);
          helpers.assertFileContent(path, new RegExp('"' + options[action].table + '"'));
          helpers.assertFileContent(path, /\,\n/);

          helpers.assertFileContent(path, new RegExp('\'id\':'));
          helpers.assertFileContent(path, /allowNull: false,/);
          helpers.assertFileContent(path, /autoIncrement: true,/);
          helpers.assertFileContent(path, /primaryKey: true,/);
          helpers.assertFileContent(path, /type: DataTypes\.INTEGER/);

          helpers.assertFileContent(path, /\)\.done\(done\)/);

          helpers.assertFileContent(path, /down = \(migration\, DataTypes\, done\) \-\>/);
          helpers.assertFileContent(path, /migration\.dropTable\(\n/);
          helpers.assertFileContent(path, new RegExp('"' + options[action].table + '"'));
          helpers.assertFileContent(path, /\)\.done\(done\)/);

          helpers.assertFileContent(path, /exports = \{\n {2}up\n {2}down\n\}/);
          helpers.assertFileContent(path, /module\.exports = exports/);
        });
      });

      describe('dropTable', function () {
        var action = 'dropTable', path;

        before(function (done) {
          generatorStart(action, function (err) {
            if (err) {
              return done(err);
            }

            path = generatedPath(action);
            done();
          });
        });

        it('create files', function () {
          assert.file(path);
        });

        it('file content', function () {

          helpers.assertFileContent(path, /up = \(migration\, DataTypes\, done\) \-\>/);
          helpers.assertFileContent(path, /migration\.dropTable\(\n/);
          helpers.assertFileContent(path, new RegExp('"' + options[action].table + '"'));
          helpers.assertFileContent(path, /\)\.done\(done\)/);

          helpers.assertFileContent(path, /down = \(migration\, DataTypes\, done\) \-\>/);
          helpers.assertFileContent(path, /done\(\)/);

          helpers.assertFileContent(path, /exports = \{\n {2}up\n {2}down\n\}/);
          helpers.assertFileContent(path, /module\.exports = exports/);
        });
      });
    });
  });
});
