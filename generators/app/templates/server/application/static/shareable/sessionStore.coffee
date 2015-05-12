
expressOptions = getLibrary('config').get('express')

sessions = require 'express-session'
redisStore = require('connect-redis') sessions

module.exports = new redisStore expressOptions.redis
