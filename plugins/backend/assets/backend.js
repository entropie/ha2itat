import "./backend.sass"

import $ from "jquery";

import { codemirror_initializer } from './codemirror_initializer.js'

$(document).ready(function() {
    if($(".cm-form").length) {
        console.log(codemirror_initializer);
        $(".cm-form").each(codemirror_initializer) //function() { })
    }
})
