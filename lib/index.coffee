redis = require 'redis'
aws = require 'aws-sdk'
promise = require 'bluebird'
path = require 'path'
fs = require 'fs'
moment = require 'moment'

class Backup

  @create: (s3Options, redisOptions) ->
    new Backup(s3Options, redisOptions)

  ###
  @param [Object] options
  @option options [Object] s3 S3 config object
  @option options [Object] redis S3 config object
  ###
  constructor: (@s3Options = {}, @redisOptions = {}) ->
    @s3Client = new aws.S3(@s3Options)
    @redisClient = @redisOptions.client || redis.createClient(@redisOptions.port, @redisOptions.host, @redisOptions.options)

  dump: ([fileName]..., cb) ->
    promise.fromNode (cb) =>
      @redisClient.save cb
    .get(1).then (dir) =>
      promise.all [
        promise.fromNode((cb) => @redisClient.config 'get', 'dir', cb).get(1)
        promise.fromNode((cb) => @redisClient.config 'get', 'dbfilename', cb).get(1)
      ]
    .spread (dir, dbfilename) =>
      promise.fromNode (callback) =>
        options =
          Bucket: @s3Options.bucket
          Key: fileName || 'redis_dump/' + moment().format('DDMMYY_HHmm') + '_' + dbfilename
          ACL: 'private'
          Body: fs.createReadStream(path.join(dir, dbfilename))
          ContentType: 'binary/octet-stream'
        @s3Client.putObject(options, callback)
    .nodeify(cb)


module.exports = Backup