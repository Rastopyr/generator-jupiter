
path = require 'path'
join = path.join

should = require 'should'

winston = require 'winston'
dateformat = require 'dateformat'

Logger = getLibrary 'core/logger'
fs = getLibrary 'core/fs'

logDirectory = join pathes.server, 'logs'

describe '#Logger', ->
	describe '#Transports', ->
		it 'custom transports should be equal transports of winston', ->
			Logger.transports.should.be.eql winston.transports

		describe '#File', ->
			it 'should be exist file constructors', () ->
				transport = getLibrary 'core/logger/transports/file'

				transport.should.be.have.property 'File'

			it 'should be function', ->
				transport = getLibrary 'core/logger/transports/file'

				transport.File.should.be.a.Function

			it 'DateFile should be instanceof winston.File', ->
				transport = getLibrary 'core/logger/transports/file'

				log = new transport.File
					logName: 'test'

				log.should.be.instanceof winston.transports.File

				fs.removeSync join logDirectory, 'test'

			it 'File should be instanceof winston.File', ->
				transport = getLibrary 'core/logger/transports/file'

				log = new transport.File
					filename: 'test.log'

				log.should.be.instanceof winston.transports.File

			it 'file should be exist', (done) ->
				filename = dateformat new Date, 'DD-MM-YYYY'

				transport = getLibrary 'core/logger/transports/file'

				log = new transport.File
					logName: 'test'

				log.log 'info', 'Test log'

				log.on 'open', ->
					log._stream.on 'finish', ->
						fs.remove (join logDirectory, 'test'), done

					log.close()
