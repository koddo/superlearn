
```
;; [clairvoyant.core :refer-macros [trace-forms]]   [re-frame-tracer.core :refer [tracer]]
;; (trace-forms {:tracer (tracer :color "green")}
;; )   ; end of trace-forms
```


TODO: make volume for lein-deps


<http://stackoverflow.com/questions/26615900/how-can-i-shorten-a-uuid-to-a-specific-length>



# markdown and mathjax together

We now have a quick and dirty fix, we process mathjax before markdown, got an idea here: <https://github.com/kerzol/markdown-mathjax/blob/master/editor.html>

This is not ideal, because we can't put latex text into quotes, it will be shown as processed spans and divs.

Would be better to protect latex (including underscores and backslashes, etc) from markdown parser and queue mathjax only after that. Here is how stackoverflow does this: <https://gist.github.com/gdalgas/a652bce3a173ddc59f66>, <https://stackoverflow.com/questions/11228558/let-pagedown-and-mathjax-work-together/35368129#35368129>


