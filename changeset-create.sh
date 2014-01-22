### Real:
#SERVER='api.openstreetmap.org'

### Test / Dev:
SERVER='api06.dev.openstreetmap.org'

USER='user_name:passwd'

curl -v -d @changeset.osm --user "$USER" \
  -H "X_HTTP_METHOD_OVERRIDE: PUT" \
  "http://$SERVER/api/0.6/changeset/create"

echo
