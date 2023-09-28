$(document).ready(function() {
    $(".clipboard-click").click(function() {
        let msg = $(this).find("span").text();
        try {
            navigator.clipboard.writeText(msg).then(() => {
                console.log('Content copied to clipboard');
                
            },() => {
                console.error('Failed to copy');
                /* Rejected - text failed to copy to the clipboard */
            })
        } catch (error) {};
        
    })
});
