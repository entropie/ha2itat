import 'codemirror/lib/codemirror.css'
import 'codemirror/theme/monokai.css'

import CodeMirror from 'codemirror';



import 'codemirror/mode/haml/haml.js'
import 'codemirror/mode/sass/sass.js'
import 'codemirror/mode/javascript/javascript.js'
import 'codemirror/mode/ruby/ruby.js'
import 'codemirror/mode/markdown/markdown.js'
//import 'codemirror/mode/gfm/gfm.js'

import 'codemirror/addon/edit/continuelist.js'
import 'codemirror/addon/fold/foldcode.js'
import 'codemirror/addon/fold/markdown-fold.js'
import 'codemirror/addon/fold/comment-fold.js'
import 'codemirror/addon/display/autorefresh.js'

//import 'codemirror/keymap/emacs.js'
import './mymacs.js'

import 'blueimp-file-upload'

import { marked } from 'marked'

import './gfm.js'
import './md5.js'
import './strftime.js'


function betterTab(cm) {
  if (cm.somethingSelected()) {
    cm.indentSelection("add");
  } else {
    cm.replaceSelection(cm.getOption("indentWithTabs")? "\t":
      Array(cm.getOption("indentUnit") + 1).join(" "), "end", "+input");
  }
}



function isUrl(s) {
    if (!isUrl.rx_url) {
        // taken from https://gist.github.com/dperini/729294
        isUrl.rx_url=/^(?:(?:https?|ftp):\/\/)?(?:\S+(?::\S*)?@)?(?:(?!(?:10|127)(?:\.\d{1,3}){3})(?!(?:169\.254|192\.168)(?:\.\d{1,3}){2})(?!172\.(?:1[6-9]|2\d|3[0-1])(?:\.\d{1,3}){2})(?:[1-9]\d?|1\d\d|2[01]\d|22[0-3])(?:\.(?:1?\d{1,2}|2[0-4]\d|25[0-5])){2}(?:\.(?:[1-9]\d?|1\d\d|2[0-4]\d|25[0-4]))|(?:(?:[a-z\u00a1-\uffff0-9]-*)*[a-z\u00a1-\uffff0-9]+)(?:\.(?:[a-z\u00a1-\uffff0-9]-*)*[a-z\u00a1-\uffff0-9]+)*(?:\.(?:[a-z\u00a1-\uffff]{2,}))\.?)(?::\d{2,5})?(?:[/?#]\S*)?$/i;
        // valid prefixes
        isUrl.prefixes=['http:\/\/', 'https:\/\/', 'ftp:\/\/', 'www.'];
        // taken from https://w3techs.com/technologies/overview/top_level_domain/all
        isUrl.domains=['com','ru','net','org','de','jp','uk','br','pl','in','it','fr','au','info','nl','ir','cn','es','cz','kr','ua','ca','eu','biz','za','gr','co','ro','se','tw','mx','vn','tr','ch','hu','at','be','dk','tv','me','ar','no','us','sk','xyz','fi','id','cl','by','nz','il','ie','pt','kz','io','my','lt','hk','cc','sg','edu','pk','su','bg','th','top','lv','hr','pe','club','rs','ae','az','si','ph','pro','ng','tk','ee','asia','mobi'];
    }
    if (!isUrl.rx_url.test(s)) return false;
    for (let i=0; i<isUrl.prefixes.length; i++)
        if (s.startsWith(isUrl.prefixes[i])) return true;
    for (let i=0; i<isUrl.domains.length; i++)
        if (s.endsWith('.'+isUrl.domains[i]) || s.includes('.'+isUrl.domains[i]+'\/') ||s.includes('.'+isUrl.domains[i]+'?')) return true;
    return false;
}

function insertString(editor, str){
    var selection = editor.getSelection();
    if(selection.length>0){
        editor.replaceSelection(str);
    } else{
        var doc = editor.getDoc();
        var cursor = doc.getCursor();

        var pos = {
            line: cursor.line,
            ch: cursor.ch
        }
        doc.replaceRange(str, pos);
    }
}

function dblclickHandler(cm, form) {
    var dbclickFunction = function(e, el) {
        let ele = $(e.srcElement);
        let ec = ele.text();
        let link;

        let refs_url =$(".references-url", $(form)).attr("value");
        if(ele.hasClass("cm-ref")) {
            window.location.href = refs_url + "/" + ec.substr(1);
        } else if (ele.hasClass("cm-url") && ele.hasClass("cm-string")) {
            let mdurl = ec.slice(1, -1).trim();
            if(isUrl(mdurl))
                window.open(mdurl, '_blank');
        } else if (ele.hasClass("cm-link") && !ele.hasClass("cm-image-alt-text")) {
            link = ec;
            if(isUrl(link))
                window.open(link, '_blank');
        } else if (ele.hasClass("cm-url")) {
            if(ec.slice(0, 1) == "(" && ec.slice(-1) === ")") {
                let mdurl = ec.slice(1, -1);
                if(isUrl(mdurl))
                    window.open(mdurl, '_blank');
            }
            return false;
        } else {
            return false;

        }
    }
    cm.getWrapperElement().addEventListener('dblclick', dbclickFunction);
    cm.getWrapperElement().addEventListener('contextmenu', dbclickFunction);
}



function installHandler(cm, form) {
    if (!cm) return;

    const rx_word = "\" "; // Define what separates a word


    function isRef(s) {
        if (!isRef.rx_url) {
            isRef.rx_url=/#(\w+)/i;
        }
        if (!isUrl(s) && isRef.rx_url.test(s)) return true;
    }


    cm.addOverlay({
        token: function(stream) {
            let ch = stream.peek();
            let word = "";

            if (rx_word.includes(ch) || ch==='\uE000' || ch==='\uE001') {
                stream.next();
                return null;
            }

            while ((ch = stream.peek()) && !rx_word.includes(ch)) {
                word += ch;
                stream.next();
            }

            if (isRef(word)) {
                // console.log("found: " + word);
                return "ref";
            }
        }}, { opaque : true }  // opaque will remove any spelling overlay etc
    );

    dblclickHandler(cm, form);
}

function getUploadUrlFromDom(upload_ident) {
    var ret;
    $(".zettel-uploads span").each(function() {
        var filename = $(this).attr("data-filename");
        if("./"+filename == upload_ident)
            ret = $(this).attr("data-url");

    })
    return ret;
}

function updateMarkdownImages(editor, widgets) {
    var markdown_imgrgx = /!\[(.*?)]\((\S+\.\w+)\)/;

    editor.operation(function(){
        for (var i = 0; i < widgets.length; ++i)
            editor.removeLineWidget(widgets[i]);
        widgets.length = 0;

        var lineString = editor.getValue();
        var arrayOfLines = lineString.split("\n");

        for (var j = 0; j < arrayOfLines.length; j++) {
            var line = arrayOfLines[j];
            var match = line.match(markdown_imgrgx);
            if(match) {
                var n = match[0];
                var alt = match[1]
                var url =  match[2];


                var msg = document.createElement("div");
                msg.className = "sheet-inline-image";
                var img = msg.appendChild(document.createElement("img"));
                var isrc = getUploadUrlFromDom(url);

                img.src = isrc;
                if(isrc == undefined)
                    img.src = url;
                widgets.push(editor.addLineWidget(j, msg));

            }

        }
    })
}

function compileMarkdownTo(ele, markdown_text) {
    let compiled_md_text = marked(markdown_text);
    $(ele).html( compiled_md_text );
}

function setupUploadline(form, editor) {

    var doc = editor.getDoc();
    var cursor = doc.getCursor();

    var pos = {
        line: cursor.line,
        ch: cursor.ch
    }

    $(".zettel-uploads span", form).each(function() {
        let upload = $(this);
        $(this).off("click");
        $(this).on("click", function() {
            doc.replaceRange("![](./" + upload.attr("data-filename") + ")\n\n", pos);
        });
    })
}

$(document).bind('drop dragover', function (e) {
    e.preventDefault();
});

window.onbeforeprint = function(event) {
    $.each(editors, function(i, e) {
        let cm = e[0];
        let form = e[1];
        compileMarkdownTo( $(form).find(".sheet-compiled"), cm.getValue());
    });
};

var editors = [];

$(document).ready(function() {
    console.log("big codemirror bro watches our backs");

    if($(".cm-form-zettel").length) {
        $(".cm-form-zettel").each(function() {

            var jform  = $(this)

            var fullform =  $(jform).parents(".zettel-create-form")
            var beditorid = $(jform).attr("id");
            var cmmode =    $(jform).attr("data-codemirror-mode");
            var widgets = []

            var beditor = CodeMirror.fromTextArea( document.getElementById(beditorid), {
                lineNumbers: false,
                lineWrapping: true,
                mode: cmmode,
                autoRefresh: true,
                matchBrackets: true,
                keyMap: "emacs",
                gitHubSpice: false,
                extraKeys: {
                    Tab: betterTab,
                    "Ctrl-X Ctrl-S": function(cm) {
                        $(fullform).submit();
                    },
                    "Ctrl-X D": function(cm) {
                        let date = new Date();
                        insertString(cm, date.strftime("%Y-%m-%d") );
                    }

                },

            });

            // save references for later use (eg. compiling markdown before printing)
            editors.push([beditor, fullform]);

            installHandler(beditor, fullform);

            var csrf_token = $(fullform).find("input[name='_csrf_token']").attr("value");
            var fub = $(fullform).fileupload({
                dropZone: $(fullform),
            });


            $(fub).on("fileuploadadd", function(e, data) {
                var url = $(fub).find(".zettel-upload-section").attr("data-upload-url");
                data.url = url + "?_csrf_token="+csrf_token;
                data.formData = data.files;

                var jqXHR = data.submit({foo: "bar"});
                jqXHR.done(function (result, textStatus, jqXHR) {
                    $.each(result, function(index, jsonObject){
                        $.each(jsonObject, function(key, val){
                            let target = $(".zettel-uploads", fullform)
                            let exist  = $("span[data-filename='"+key+"']", target);

                            if(exist.length == 0) {
                                let ele2add = document.createElement("span");
                                let eleimg = document.createElement("img");
                                eleimg.src = val;
                                $(ele2add).attr("data-filename", key)
                                $(ele2add).attr("data-url", val)
                                $(ele2add).append(eleimg);
                                target.append(ele2add);
                                fChangeFunction();
                                $(fullform).fadeOut(100).fadeIn(100);
                            }
                        })
                    });
                });
            });


            $(fub).on("fileuploadprogress", function(e, data) {
                var progress = parseInt(data.loaded / data.total * 100, 10);
                console.log(progress);
            })


            var hash = md5(beditor.doc.getValue());
            var orig_title = $(fullform).find(".sheet-edit-title").val();


            var fChangeFunction = function() {
                var cur_title = $(fullform).find(".sheet-edit-title");
                var title_changed = orig_title !== cur_title.val();
                if(title_changed || hash != md5(beditor.doc.getValue()))
                    $(fullform).addClass("edited");
                else
                    $(fullform).removeClass("edited");

                setupUploadline(fullform, beditor);

                setTimeout(function() {
                    updateMarkdownImages(beditor, widgets);
                }, 100)
            }

            fChangeFunction.call();

            $(fullform).find(".sheet-edit-title").on('input', fChangeFunction);
            beditor.on("change", fChangeFunction);

        })
    }
});
