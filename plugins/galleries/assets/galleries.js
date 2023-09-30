import 'jquery';
import { magnificPopup } from 'magnific-popup'
import 'magnific-popup/dist/magnific-popup.css'


$(document).ready(function() {

    if($(".popup-img").length)
        $('.popup-img').magnificPopup({
            type: 'image',
            autoFocusLast: false,
            fixedContentPos: false
        });
    
    if($(".open-popup-link").length)
        $('.open-popup-link').magnificPopup({
            type:'inline',
            autoFocusLast: false,
            fixedContentPos: false
        });

    if($(".open-popup-alink").length)
        $('.open-popup-alink').magnificPopup({
            type:'ajax',
            autoFocusLast: false,
            fixedContentPos: false
        });

    // copy ident to clipboard onClick on :backend_galleries_index
    $(".clipboard-click").click(function() {
        let dataToCopy = $(this).attr("data-clipboard-content");
        let msg = $(this).find("span").text();
        if(dataToCopy)
            msg = dataToCopy;

        try {
            navigator.clipboard.writeText(msg)
        } catch (error) {};
        
    })
});
