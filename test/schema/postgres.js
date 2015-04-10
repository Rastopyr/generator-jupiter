/*globals it, describe, before */
'use strict';

var path = require('path');
var assert = require('yeoman-generator').assert;
var helpers = require('yeoman-generator').test;
var os = require('os');

describe('jupiter:schema', function () {
  describe('postgres', function () {
    describe('with coffee', function () {
      var fixture, tmpDir, expectedFilePath;

      tmpDir = path.join(os.tmpdir(), './temp-test');

      fixture = {
        type: 'Postgres',
        format: 'coffee',
        schemaname: 'schema-' + (new Date()).getTime(),
        tableName: 'table-' + (new Date()).getTime(),
        filename: 'schema-' + (new Date()).getTime(),
        relpath: 'relpath',
        timestamps: false,
        underscored: true,
        addnew: false,
        correct: true
      };

      expectedFilePath = path.join(
        'server/application/model/',
        fixture.relpath,
        fixture.filename + '.' + fixture.format
      );

      before(function (done) {
        helpers.run(path.join(__dirname, '../../generators/schema/index'))
          .inDir(tmpDir)
          .withPrompt(fixture)
          .on('end', done);
      });

      it('creates file', function () {
        assert.file(expectedFilePath);
      });

      it('file content', function () {
        helpers.assertFileContent(expectedFilePath, /Sequelize = require 'sequelize'/);
        helpers.assertFileContent(expectedFilePath, /schema =\n/);
        helpers.assertFileContent(expectedFilePath, new RegExp('allowNull: false,'));
        helpers.assertFileContent(expectedFilePath, new RegExp('autoIncrement: true,'));
        helpers.assertFileContent(expectedFilePath, new RegExp('primaryKey: true,'));
        helpers.assertFileContent(expectedFilePath, new RegExp('type: Sequelize.INTEGER'));
        helpers.assertFileContent(expectedFilePath, /options =\n/);
        helpers.assertFileContent(expectedFilePath, new RegExp('tableName: \"' + fixture.tableName + '\"'));
        helpers.assertFileContent(expectedFilePath, new RegExp('timestamps: ' + fixture.timestamps));

        if (fixture.timestamps) {
          helpers.assertFileContent(expectedFilePath, new RegExp('paranoid: ' + (fixture.paranoid || fixture.timestamps)));
        }

        helpers.assertFileContent(expectedFilePath, new RegExp('underscored: ' + fixture.underscored));
        helpers.assertFileContent(expectedFilePath, new RegExp('name = \"' + fixture.schemaname + '\"'));
        helpers.assertFileContent(expectedFilePath, new RegExp('type = \"Postgres\"'));

        helpers.assertFileContent(expectedFilePath, /module\.exports = exports = \{\n {2}schema\n {2}name\n {2}options\n {2}type\n\}/);
      });
    });
  });
});
