
# run locally checklist

- run superlearn-wiki
- database restore
- docker-compose up -d






# most interesting parts

<./backend/src/hello_world_app.erl> and handlers
<./client-web/src/cljs/theproject/views.cljs>, etc
database/V*_funcs__*.sql


# security

TODO: SECURITY make sure iframe-resizer is safe, can't be used for xss and csrf
TODO: SECURITY make sure marked.js is safe: <https://ponyfoo.com/articles/fixing-xss-vulnerability-marked>, <https://snyk.io/blog/marked-xss-vulnerability/>

# fsevents

<https://facebook.github.io/watchman/>
<https://geoff.greer.fm/fsevents/>, <https://geoff.greer.fm/2015/12/25/fsevents-tools-watch-a-directory-for-changes/>


# misc

<https://developer.yahoo.com/performance/rules.html>


TODO: <https://docs.docker.com/compose/compose-file/#variable-substitution> in .env for external ports

# sort

<https://www.slideshare.net/stormpath/rest-jsonapis>
<https://www.sitepoint.com/best-practices-rest-api-scratch-introduction/>
<http://www.vinaysahni.com/best-practices-for-a-pragmatic-restful-api>
<https://blog.mwaysolutions.com/2014/06/05/10-best-practices-for-better-restful-api/>


# SECURITY -- escaping html

We now rely on `sanitaize` option of `marked()` after decoding html entities from user data.

<https://stackoverflow.com/questions/1147359/how-to-decode-html-entities-using-jquery/1395954#1395954>
TODO: use HTML entity encoder/decoder lib instead of relying on textarea: <https://github.com/mathiasbynens/he>


