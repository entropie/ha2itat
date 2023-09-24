import "jquery-datetimepicker"
import "jquery-datetimepicker/jquery.datetimepicker.css"

import { compareAsc, format,add } from 'date-fns'

function setBookingIdentField(regexp, val) {
    let identfield = $('#events-edit input[name="ident"]');
    if( identfield.is(':disabled') )
        return false;
    let newident = identfield.val().replace(regexp, val);
    identfield.attr("value", newident);
}

function replaceIdentFromTypeChange() {
    setBookingIdentField(/^[\w\s]+--/, $(this).find(':selected').data("humantype") + "--")
}

function dateLineLinkclick() {
    let dl = $(this);
    $(dl).find(".remove-day-link").click(function() {
        dl.remove();
    });
}

const eventFormDatePickerSync = {
        timepicker: true,
        onChangeDateTime:function(dp,$input){
            var date, datestr;
            if($input.attr("name") === "dates[begin][]") {
                date = new Date(Date.parse($input.val()));
                date = add(date, { minutes: 60 })
                datestr = format(date, "yyyy/MM/dd HH:mm");
                setBookingIdentField(/\d\d?\-\d\d$/, format(date, "II-yy"))
                $input.parent().parent().parent().parent().find('input[name="dates[end][]"]').attr("value", datestr)
            }
        }
}


jQuery.datetimepicker.setLocale('de');


$(document).ready(function() {
    
    $('.datepicker').datetimepicker(eventFormDatePickerSync);



    if($("#events-edit").length) {
        $("#add-date-template-link").click(function() {
            let ele2copy = $("#add-date-template .date-line:last-child").clone();
            ele2copy.find(".datepicker").datetimepicker();
            $(ele2copy).each(dateLineLinkclick);
            ele2copy.insertAfter( $("#events-edit .date-line").filter(":last") ).addClass("toadd");

            $('.datepicker').datetimepicker(eventFormDatePickerSync);
        });

        $('#events-edit select[name="type"]').each(function() {
            $(this).on('change', replaceIdentFromTypeChange)
        });

        $(".date-line").each(dateLineLinkclick);
    }

})
