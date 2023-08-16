function parser() {
    // 取得圖片 host
    let filePath = pVars.manga.filePath;
    // 取得圖片 array 字串
    let files = eval($('body').contents()[7].text.match(/\(function\(p,a,c,k,e,d\).*/)[0]).match(/\[.*\]/);
    // 轉成 Array
    let array = JSON.parse(files);
    var result = [];

    array.forEach(function(element) {
        let uri = filePath + element;
        result.push(uri);
    });

    return result;
}

parser();
