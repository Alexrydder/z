#!/bin/bash
# Publishes go.gablvm.org: adds the tunnel ingress rule to the running
# Cloudflare tunnel and the proxied CNAME record. Idempotent.
set -eu
E=$(drush-gablvm config:get gablvm_security.settings cloudflare_api_email --format=string 2>/dev/null)
K=$(drush-gablvm config:get gablvm_security.settings cloudflare_api_key --format=string 2>/dev/null)
ACC=$(cat /root/.cf-account-id); TID=$(cat /root/.cf-tunnel-id); ZONE=$(cat /root/.cf-zone-gablvm)
H=(-H "X-Auth-Email: $E" -H "X-Auth-Key: $K" -H "Content-Type: application/json")
API=https://api.cloudflare.com/client/v4
CFG=$(curl -s "${H[@]}" "$API/accounts/$ACC/cfd_tunnel/$TID/configurations")
NEW=$(echo "$CFG" | python3 -c "
import sys,json;c=json.load(sys.stdin)['result']['config'];ing=c.get('ingress',[])
if not any(i.get('hostname')=='go.gablvm.org' for i in ing):
    ing.insert(len(ing)-1, {'hostname':'go.gablvm.org','service':'http://localhost:3000','originRequest':{}})
c['ingress']=ing;print(json.dumps({'config':c}))")
curl -s -X PUT "${H[@]}" "$API/accounts/$ACC/cfd_tunnel/$TID/configurations" --data "$NEW" | python3 -c "import sys,json;r=json.load(sys.stdin);print('ingress',r['success'],r['errors'])"
EXIST=$(curl -s "${H[@]}" "$API/zones/$ZONE/dns_records?name=go.gablvm.org" | python3 -c "import sys,json;r=json.load(sys.stdin)['result'];print(r[0]['id'] if r else '')")
BODY="{\"type\":\"CNAME\",\"name\":\"go\",\"content\":\"$TID.cfargotunnel.com\",\"proxied\":true,\"ttl\":1}"
if [ -n "$EXIST" ]; then curl -s -X PUT "${H[@]}" "$API/zones/$ZONE/dns_records/$EXIST" --data "$BODY"; else curl -s -X POST "${H[@]}" "$API/zones/$ZONE/dns_records" --data "$BODY"; fi | python3 -c "import sys,json;r=json.load(sys.stdin);print('dns',r['success'],r['errors'])"
