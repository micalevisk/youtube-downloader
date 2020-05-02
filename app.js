const { join } = require('path')
const { networkInterfaces } = require('os')
const Fastify = require('fastify')
const serve = require('fastify-static')
const ytdl = require('ytdl-core')

const PORT = process.env.PORT || 8080

const fastify = Fastify({ logger: true, ignoreTrailingSlash: true })

const getNetworkAddress = () => {
  const interfaces = networkInterfaces()
  for (const name of Object.keys(interfaces)) {
    for (const interface of interfaces[name]) {
      const {address, family, internal} = interface
      if (family === 'IPv4' && !internal) {
        return address
      }
    }
  }
}

fastify.listen(PORT, '0.0.0.0', (err, address) => {
  if (err) {
    fastify.log.error(err)
    process.exit(1)
  }

  const { port } = fastify.server.address()
  const ip = getNetworkAddress()
  if (ip && port) {
    const networkAddress = `http://${ip}:${port}`
    fastify.log.info(`Server listening at ${networkAddress}`)
  }
})


fastify.register(serve, {
  root: join(__dirname, 'public'),
  prefix: '/'
})


const sanitizeFilename = filename => filename.replace(/"/g, '') // helper
const optsByFormat = new Map([
  // maps container to ytdl-core `ytdl` options
  ['mp3', { format: 'mp3', quality: 'highestaudio' , filter: 'audioonly' }],
  ['mp4', { format: 'mp4', quality: 'highest' }],
])

const schema = {
  params: {
    type: 'object',
    properties: {
      format: { type: 'string', enum: [...optsByFormat.keys()] }
    }
  },
  querystring: {
    type: 'object',
    properties: {
      url: { type: 'string' }
    },
    required: ['url']
  }
}

fastify.get('/download/:format', { schema }, async (request, reply) => {
  const { url } = request.query
  const { format } = request.params

  const videoInfo = await ytdl.getBasicInfo(decodeURIComponent(url))
  const title = videoInfo.player_response.videoDetails.title || 'audio'

  const filename = `${sanitizeFilename(title)}.${format}`
  reply.header('Content-Disposition', `attachment; filename="${filename}"`)

  reply.send(
    ytdl(url, optsByFormat.get(format))
  )
})

