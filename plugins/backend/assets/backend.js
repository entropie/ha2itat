import "./backend.sass"

import "./pager.sass"

import $ from "jquery";


import "./codemirror.sass"
import { codemirror_initializer } from './codemirror_initializer.js'


$(document).ready(function() {

    if($(".cm-form").length) {
        $(".cm-form").each(function() {
            codemirror_initializer($(this));
        })
    }

})
