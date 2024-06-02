//
//  Images.js
//
//  Created by Shinren Pan on 2024/5/24.
//
//

function parser() {
    // 取得圖片 host
    let filePath = pVars.manga.filePath;
    // 取得圖片 array 字串
    let files = eval($('script').filter(function(){
        return $(this).text().match(/\(function\(p,a,c,k,e,d\).*/);
    })[0].text.match(/\(function\(p,a,c,k,e,d\).*/)[0]).match(/\[.*\]/);

    // 轉成 Array
    let array = JSON.parse(files);
    var result = [];

    array.forEach(function(element, index) {
        let image = new Object();
        image.index = index;
        image.uri = filePath + element;
        result.push(image);
    });

    return result;
}

parser();
