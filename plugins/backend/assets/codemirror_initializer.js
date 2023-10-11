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


export function codemirror_initializer(form, force = false) {
    var jform = form;

    var beditorid = jform.attr("id");
    var cmmode = $(jform).attr("data-codemirror-mode");

    if((jform.attr("noauto") !== undefined) && force !== true) {
        return false;
    }

    var beditor = CodeMirror.fromTextArea( document.getElementById(beditorid), {
        lineNumbers: false,
        lineWrapping: true,
        mode: cmmode,
        autoRefresh: true,
        matchBrackets: true,
        extraKeys: { Tab: betterTab },
        height: "100%"
    });
    return beditor;

}
