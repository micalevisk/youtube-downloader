# youtube-downloader

![demo](./demo.png)

```bash
npm install

npm start
## or
npm run start:dev
## or
npm run dev
## or (to use `docker-compose`)
PORT=8080 npm run up
PORT=8080 npm run logs

# and go to http://localhost:8080
```

## local usage

```bash
# initialize the app on Docker container
PORT=4000 npm run up
```

Add a `/etc/hosts` entry like the following:

```
1270.0.0.2 ytd.com
```

Then you add an iptables rule to redirect the traffic incoming into `127.0.0.2:4000` to `127.0.0.1:80`:

```bash
iptables -t nat -A OUTPUT -d 127.0.0.2 -p tcp --dport 80 -j REDIRECT --to-port 4000
```

Now you can access the app in your browser through http://ytd.com or  
in your network through `http://<your IP>:4000` address

## development using `docker-compose`

> doing a [pure-Docker development](https://www.docker.com/blog/keep-nodejs-rockin-in-docker)

```bash
# Initial setup:
npm install
export PORT=8080
npm run up
npm run logs

## Open the entry file `app.js` in your favorite text editor.
## Changes will reload the server.

# In another shell session:
export PORT=8080
## to install dependencies in container
npm run add <dependency name ...>
## to remove dependencies in container
npm run remove <dependency name ...>
```

