# distributed-press-clone-site
Clone an existing website to Distributed Press using wget2

## Dependencies:

- posix compliant bash shell
- curl
- wget2
- jq

## Usage

```bash
# Only set this if you're self hosting with your own instance
export DP_SERVER_URL="https://api.distributed.press"

# Generate a "publisher token" for your account
export DP_AUTH_TOKEN=<token here>

./clone www.example.com
```

Your P2P links will then be output to the console.
TO get "pretty" links, add a [DNSLink](https://www.dnslink.io/) record by adding an `NS` record pointing to `_dnslink.<yourdomain>` to `api.distributed.press`. This will instruct clients to ask for p2p URLs from the DP server automatically.

## How it works

The script uses wget2 to crawl and download your site into static files. It then uploads those files to distributed.press in a tar file which then causes them to be published to the p2p protocols supported by DP.