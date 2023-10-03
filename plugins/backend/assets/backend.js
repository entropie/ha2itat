import "./backend.sass"

import $ from "jquery";

import { codemirror_initializer } from './codemirror_initializer.js'

import "./tagsinput.js"


$(document).ready(function() {

    if($(".cm-form").length) {
        $(".cm-form").each(function() {
            codemirror_initializer($(this));
        })
    }

})
