backup = require('./index')
argv = require('yargs')
  .demand(['accessKeyId', 'secretAccessKey', 'bucket'])
  .usage('Usage: $0 <command> [options]')
  .describe('endpoint', 'endpoint')
  .describe('accessKeyId', 'accessKeyId')
  .describe('secretAccessKey', 'secretAccessKey')
  .describe('bucket', 'bucket')
  .describe('redisHost', 'redisHost')
  .describe('redisPort', 'redisPort')
  .descript('dumpFile', 'dumpFile')
  .alias('a', 'accessKeyId')
  .alias('s', 'secretAccessKey')
  .alias('b', 'bucket')
  .help('h')
  .argv

redisOptions = {
  port: argv.redisPort
  host: argv.redisHost
}

s3Options = {
  accessKeyId: argv.accessKeyId
  secretAccessKey: argv.secretAccessKey
  bucket: argv.bucket
  endpoint: argv.endpoint
}

backup.create(s3Options, redisOptions).dump argv.dumpFile, (err) ->
  if (err)
    console.error(err)
    process.exit(1)
  else
    console.log('data dumped succesfully')
    process.exit(0)
