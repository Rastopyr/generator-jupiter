/*globals it, describe, before */
'use strict';

var path = require('path');
var assert = require('yeoman-generator').assert;
var helpers = require('yeoman-generator').test;
var os = require('os');

describe('jupiter:fixture', function () {
  describe('postgres', function () {
    describe('with coffee', function () {
      describe('multiple', function () {
        var fixture, tmpDir, expectedFilePath;

        tmpDir = path.join(os.tmpdir(), './temp-test');

        fixture = {
          type: 'Postgres',
          format: 'coffee',
          ftype: 'multiple',
          name: 'fixture-' + (new Date()).getTime(),
          filename: 'fixture-' + (new Date()).getTime(),
          relpath: 'relpath',
          correct: true
        };

        expectedFilePath = path.join(
          'server/application/fixtures/',
          fixture.relpath,
          fixture.filename + '.' + fixture.format
        );

        before(function (done) {
          helpers.run(path.join(__dirname, '../../generators/fixture/index.js'))
            .inDir(tmpDir)
            .withPrompt(fixture)
            .on('end', done);
        });

        it('creates file', function () {
          assert.file([
            expectedFilePath
          ]);
        });

        it('file content', function () {
          helpers.assertFileContent(expectedFilePath, new RegExp('name = \"' + fixture.name + '\"'));
          helpers.assertFileContent(expectedFilePath, new RegExp('data = \\[\\]'));
          helpers.assertFileContent(expectedFilePath, new RegExp('exports = {\n  name\n  data\n}'));
          helpers.assertFileContent(expectedFilePath, new RegExp('module.exports = exports'));
        });
      });

      describe('singular', function () {
        var fixture, tmpDir, expectedFilePath;

        tmpDir = path.join(os.tmpdir(), './temp-test');

        fixture = {
          type: 'Postgres',
          format: 'coffee',
          ftype: 'single',
          name: 'fixture-' + (new Date()).getTime(),
          filename: 'fixture-' + (new Date()).getTime(),
          relpath: 'relpath',
          correct: true
        };

        expectedFilePath = path.join(
          'server/application/fixtures/',
          fixture.relpath,
          fixture.filename + '.' + fixture.format
        );

        before(function (done) {
          helpers.run(path.join(__dirname, '../../generators/fixture/index.js'))
            .inDir(tmpDir)
            .withPrompt(fixture)
            .on('end', done);
        });

        it('creates file', function () {
          assert.file([
            expectedFilePath
          ]);
        });

        it('file content', function () {
          helpers.assertFileContent(expectedFilePath, new RegExp('name = \"' + fixture.name + '\"'));
          helpers.assertFileContent(expectedFilePath, new RegExp('data = null'));
          helpers.assertFileContent(expectedFilePath, new RegExp('exports = {\n  name\n  data\n}'));
          helpers.assertFileContent(expectedFilePath, new RegExp('module.exports = exports'));
        });
      });
    });
  });
});
