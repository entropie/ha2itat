import 'jquery-tags-input/src/jquery.tagsinput.js'

import "./tagsinput.sass"

$(document).ready(function() {
    $(".tags-input").tagsInput(
        {
            // 'autocomplete_url': url_to_autocomplete_api,
            // 'autocomplete': { option: value, option: value},
            'height':'auto',
            'width':'100%',
            // 'interactive':true,
            // 'defaultText':'add a tag',
            // 'onAddTag':callback_function,
            // 'onRemoveTag':callback_function,
            // 'onChange' : callback_function,
            // 'delimiter': [',',';'],   // Or a string with a single delimiter. Ex: ';'
            // 'removeWithBackspace' : true,
            // 'minChars' : 0,
            // 'maxChars' : 0, // if not provided there is no limit
            // 'placeholderColor' : '#666666'
        });
});
