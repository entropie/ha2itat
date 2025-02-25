function formatBytes(bytes, decimals = 2) {
    if (!+bytes) return '0 Bytes'

    const k = 1024
    const dm = decimals < 0 ? 0 : decimals
    const sizes = ['Bytes', 'KiB', 'MiB', 'GiB', 'TiB', 'PiB', 'EiB', 'ZiB', 'YiB']

    const i = Math.floor(Math.log(bytes) / Math.log(k))

    return `${parseFloat((bytes / Math.pow(k, i)).toFixed(dm))} ${sizes[i]}`
}

function logProgess(message) {
    let target = $("#clytdlp-client").length ? $("#clytdlp-client") : $("#climgdl-client")
    target.append("<p><strong>&gt; </strong>" + message + "</p>");
}

function loadJSON(url, callback) {
    var xhr = new XMLHttpRequest();
    xhr.onreadystatechange = function() {
        if (xhr.readyState === 4 && xhr.status === 200) {
            var json = JSON.parse(xhr.responseText);
            callback(json);
        }
    };
    logProgess(`downloading json from <code>${url}</code>`)
    xhr.open("GET", url, true);
    xhr.send();
}

function getAndUploadMediaByUrl(media_url, target_url, content) {
    let dl = function(url, callback) {
        var xhr = new XMLHttpRequest();
        xhr.open("GET", url, true);
        xhr.responseType = "blob";
        xhr.onload = function() {
            if (xhr.status === 200) {
                console.log(xhr)
                logProgess("<span style='color:green'>success</span>")
                logProgess(`size is <b>${formatBytes(xhr.response.size)}</b>`)
                callback(xhr.response);
            }
        };
        logProgess("trying to download...")
        xhr.send();

    }


    let ul = function(file, target_url) {
        var formData = new FormData();
        var target;

        if( $("#clytdlp-client").length )
            target = $("#clytdlp-client");
        else
            target = $("#climgdl-client");

        var csrf_token = target.attr("data-csrf-token");

        formData.append("file", file);
        formData.append("_csrf_token", csrf_token);
        formData.append("content", content);
        formData.append("media_url", media_url);
        var xhr = new XMLHttpRequest();

        logProgess(`uploading to <code>${target_url}</code>...`)

        xhr.open("POST", target_url, true);
        xhr.onload = function() {
            if (xhr.status === 200) {
                var res = JSON.parse(xhr.responseText)
                var url = res["url"];
                logProgess(`upload <span style='color:green'>success</span>; <a href="${url}">${url}</a>`)

            }
        };
        xhr.send(formData);
    }

    dl(media_url, function(file) {
        ul(file, target_url);
    })
}

function clytdlp(content) {
    console.log("clytdlp starting with", content)
    var url = content.slice(0, -1) + ".json";

    loadJSON(url, function(resp) {
        let media_url = resp[0]['data']['children'][0]['data']['media']['reddit_video']['fallback_url'];
        logProgess(`extracted media url <code>${media_url}</code>`)
        let upload_url = $("#clytdlp-client").attr("data-create-url");
        getAndUploadMediaByUrl(media_url, upload_url, content);
    });

    return true;
}

function climgdl(content) {
    console.log("climgdl starting with", content)
    var url = content;
    var create_url = $("#climgdl-client").attr("data-create-url");

    logProgess(`(down|up)loading <code>${url}</code> to <code>${create_url}</code>`);
    getAndUploadMediaByUrl(url, create_url, content)
    return true;
}



$(document).ready(function() {
    if( $("#clytdlp-client").length ) {
        clytdlp($("#clytdlp-content").text());
    }
    if( $("#climgdl-client").length ) {
        climgdl($("#climgdl-content").text());
    }
})
