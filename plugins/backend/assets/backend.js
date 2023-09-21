import "./backend.sass"

import $ from "jquery";

import CodeMirror from 'codemirror';
import 'codemirror/lib/codemirror.css'
import 'codemirror/theme/monokai.css'


import 'codemirror/keymap/emacs'
import 'codemirror/mode/haml/haml.js'
import 'codemirror/mode/sass/sass.js'
import 'codemirror/mode/javascript/javascript.js'
import 'codemirror/mode/markdown/markdown.js'
import 'codemirror/addon/edit/continuelist.js'
import 'codemirror/addon/fold/foldcode.js'
import 'codemirror/addon/fold/markdown-fold.js'
import 'codemirror/addon/fold/comment-fold.js'
import 'codemirror/addon/display/autorefresh.js'



function betterTab(cm) {
  if (cm.somethingSelected()) {
    cm.indentSelection("add");
  } else {
    cm.replaceSelection(cm.getOption("indentWithTabs")? "\t":
      Array(cm.getOption("indentUnit") + 1).join(" "), "end", "+input");
  }
}

$(document).ready(function() {
    if($(".cm-form").length) {
        $(".cm-form").each(function() {

            var jform  = $(this)
            var beditorid = jform.attr("id");
            // console.log(beditorid, $(jform).attr("data-codemirror-mode"));
            var cmmode = $(jform).attr("data-codemirror-mode");
            // if($(".cm-mode")) {
            //     console.log( $(".cm-mode").find("option:selected").val() );
            // }
            var beditor = CodeMirror.fromTextArea( document.getElementById(beditorid), {
                lineNumbers: false,
                lineWrapping: true,
                mode: cmmode,
                autoRefresh: true,
                matchBrackets: true,
                extraKeys: { Tab: betterTab },
                height: "100%"
            });
        })
    }
})
