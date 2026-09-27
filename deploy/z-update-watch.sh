#!/bin/bash
# Keeps the Z short link service current, the way drupal-update-watch.sh
# keeps gablvm.org current. Daily from root cron.
#   1. Fetch upstream (UMN-LATIS/z, branch develop). No new commits: exit quietly.
#   2. Merge into our gablvm branch. A conflict aborts the merge and emails.
#   3. Rebuild the production image, keep the previous one as z-app:previous.
#   4. Restart z-web, smoke test /, /faq and a known short link.
#   5. On failure: restore the previous image and branch tip, restart, email URGENT.
#   6. On success: push the branch to the public fork (AGPL source offer), email.
# A monthly base rebuild (first run of the month) refreshes the Rocky, Ruby
# and Node layers so OS and interpreter fixes land too.
set -u
REPO=/srv/z
LOG=/var/log/z-update-watch.log
MAIL=/root/bin/gablvm-mail
TO=yabdikad@gmail.com
AUTHOR=(-c user.name=Alexrydder -c user.email=155053931+Alexrydder@users.noreply.github.com)
log() { echo "[$(date -u +%FT%TZ)] $*" >> "$LOG"; }
email() { # subject, html
  python3 - "$1" "$2" "$TO" <<'PY' | "$MAIL" >/dev/null 2>&1 || log "WARN: email failed"
import json,sys
s,h,to=sys.argv[1:4]
print(json.dumps({"to":to,"from":{"address":"noreply@gablvm.org","name":"Claude Code"},"subject":s,"text":"HTML email from z-update-watch.","html":h}))
PY
}
smoke() {
  local ok=1
  for i in $(seq 1 45); do curl -s -o /dev/null -w '%{http_code}' http://127.0.0.1:3000/ 2>/dev/null | grep -q '^200$' && break; sleep 2; done
  [ "$(curl -s -o /dev/null -w '%{http_code}' -H 'Host: go.gablvm.org' http://127.0.0.1:3000/)" = 200 ] || ok=0
  [ "$(curl -s -o /dev/null -w '%{http_code}' -H 'Host: go.gablvm.org' http://127.0.0.1:3000/faq)" = 200 ] || ok=0
  [ "$(curl -s -o /dev/null -w '%{http_code}' -H 'Host: go.gablvm.org' http://127.0.0.1:3000/privacy)" = 302 ] || ok=0
  [ "$ok" = 1 ]
}
cd "$REPO" || exit 1
log "=== run start ==="
git fetch -q origin develop || { log "fetch failed"; exit 1; }
BEFORE=$(git rev-parse HEAD)
NEW=$(git rev-list --count HEAD..origin/develop)
MONTHLY=0; [ "$(date +%d)" = 01 ] && MONTHLY=1
if [ "$NEW" = 0 ] && [ "$MONTHLY" = 0 ]; then log "up to date at $BEFORE"; log "=== run complete ==="; exit 0; fi
log "upstream new commits: $NEW monthly_base_rebuild=$MONTHLY"
if [ "$NEW" != 0 ]; then
  if ! git "${AUTHOR[@]}" merge -q --no-edit origin/develop >> "$LOG" 2>&1; then
    git merge --abort
    log "MERGE CONFLICT, left untouched at $BEFORE"
    email "Z short links: upstream merge conflict, no change made" "<h1>Z update needs a hand</h1><p>Upstream UMN-LATIS/z has $NEW new commits and the merge into the gablvm branch conflicts. Nothing was changed, go.gablvm.org keeps running the current build. Resolve in /srv/z and run /srv/z/deploy/z-update-watch.sh again.</p><pre>$(git diff --name-only --diff-filter=U 2>/dev/null | head -20)</pre>"
    log "=== run complete ==="; exit 1
  fi
fi
AFTER=$(git rev-parse HEAD)
podman tag localhost/z-app:prod localhost/z-app:previous 2>/dev/null
if [ "$MONTHLY" = 1 ]; then
  log "rebuilding base image"
  podman build --no-cache -q -f docker/Dockerfile -t z-app:dev . >> "$LOG" 2>&1 || { log "base build failed"; git reset -q --hard "$BEFORE"; email "Z short links: base image build FAILED" "<h1>Base image build failed</h1><p>Branch reset to $BEFORE, service untouched. See $LOG.</p>"; exit 1; }
fi
if ! podman build -q -f docker/Dockerfile.prod -t z-app:prod . >> "$LOG" 2>&1; then
  log "prod build failed, restoring"
  podman tag localhost/z-app:previous localhost/z-app:prod; git reset -q --hard "$BEFORE"
  email "Z short links: image build FAILED, rolled back" "<h1>Build failed</h1><p>The new image did not build. Branch reset to $BEFORE, previous image kept, service untouched. See $LOG.</p>"
  log "=== run complete ==="; exit 1
fi
systemctl restart z-web.service
if smoke; then
  log "smoke OK at $AFTER"
  git push -q fork gablvm >> "$LOG" 2>&1 || log "WARN: push to fork failed"
  LIST=$(git log --format='<li>%s</li>' "$BEFORE".."$AFTER" | head -30)
  email "Z short links updated ($NEW upstream commits)" "<h1>go.gablvm.org updated</h1><p>Merged $NEW upstream commits, rebuilt, restarted, smoke test passed (home, FAQ, one short link). Source pushed to the fork.</p><h2>Commits</h2><ul>$LIST</ul>"
else
  log "SMOKE FAILED, rolling back to $BEFORE"
  podman tag localhost/z-app:previous localhost/z-app:prod; git reset -q --hard "$BEFORE"; systemctl restart z-web.service
  if smoke; then log "rollback OK"; R="Rolled back to the previous build, which passed the smoke test."; else log "ROLLBACK ALSO FAILED"; R="Rollback ALSO failed, go.gablvm.org may be down."; fi
  email "URGENT Z short links: update failed smoke test" "<h1>Update failed</h1><p>The new build did not answer correctly. $R Branch is back at $BEFORE. See $LOG.</p>"
fi
log "=== run complete ==="
