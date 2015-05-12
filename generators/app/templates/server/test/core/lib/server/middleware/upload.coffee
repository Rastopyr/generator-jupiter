
path = require 'path'
join = path.join

should = require 'should'
request = require 'supertest'

index = require '../../../../../core/index'

Server = getLibrary 'core/server'
fs = getLibrary 'core/fs'
uploadMiddleware = getLibrary 'core/server/middleware/upload'

imagePath = join pathes.server, 'test/files/upload.jpg'
imageDir = join pathes.base, 'static/uploads'

describe '#Middleware', ->
	describe '#Uploader', ->
		it 'should be Function', ->
			uploadMiddleware.should.be.Function

		it 'should be return Function', ->
			uploadMiddleware().should.be.Function

		it 'should be upload image', (done) ->
			server = new Server
			
			server.use '/', uploadMiddleware
				dest: join pathes.base, 'static/uploads'

			server.use '/', (req, res, next) ->
				res.json req.files

			request(server.express)
				.post('/')
				.attach('file', imagePath)
				.expect(200)
				.end (err, res) ->
					should(err).eql null
					response = JSON.parse res.text

					uploaded = fs.lstatSync join imageDir, response.file.name

					uploaded.isFile().should.be.ok

					fs.remove join(pathes.base, 'static/uploads', response.file.name), done

		it 'should be append data to req.body after upload', (done) ->
			server = new Server

			server.use '/', uploadMiddleware
				field: 'wallpaper'

			server.use '/', (req, res, next) ->
				req.body.should.have.property 'wallpaper'
				req.body.wallpaper.should.eql req.files.wallpaper.name

				res.json req.body

			request(server.express)
				.post('/')
				.attach('wallpaper', imagePath)
				.expect(200)
				.end (err, res) ->
					should(err).eql null
					response = JSON.parse res.text

					image = response.wallpaper

					fs.remove join(pathes.base, 'static/uploads', image), done

		it 'should be upload to relDest path', (done) ->

			server = new Server

			server.use '/', uploadMiddleware
				relDest: 'profile'

			server.use '/', (req, res, next) ->
				res.json req.files

			request(server.express)
				.post('/')
				.attach('wallpaper', imagePath)
				.expect(200)
				.end (err, res) ->
					should(err).eql null
					response = JSON.parse res.text

					image = response.wallpaper

					exist = fs.lstatSync join(pathes.base, 'static/uploads/profile', image.name)

					if not exist.isFile()
						return done new Error 'Uploaded file not exist'

					fs.remove join(pathes.base, 'static/uploads/profile'), done


