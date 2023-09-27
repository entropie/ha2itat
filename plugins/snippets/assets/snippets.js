import { codemirror_initializer } from '../../backend/assets/codemirror_initializer.js'

const content_types = {
    markdown: "text/x-markdown",
    haml: "text/x-haml"
}

$(document).ready(function() {

    // we seperate logic for snippet form here because we want to change the mode
    // for the editor, depending on snippet type (haml or markdown)
    var cm;
    var cmform = $("#BE-form.snippets .cm-form");
    let ele = $("#BE-form.snippets select[name=extension]");

    cmform.each(function(ele) {
        cm = codemirror_initializer($(this), true);
    })

    ele.change(function() {
        let selected_ele = $("option:selected", ele)
        let content_type_from_select = content_types[ selected_ele.attr("value") ];
        if(content_type_from_select) {
            cm.toTextArea();
            cmform.attr("data-codemirror-mode", content_type_from_select);
            cm = codemirror_initializer(cmform, true);
        }
    });

})
