//
//  Update.js
//
//  Created by Shinren Pan on 2024/5/21.
//

var results = [];
var list = $('.latest-list > ul > li');

var length = list.length;

list.each(function() {
    var comic = new Object();
    // https://stackoverflow.com/a/55927526
    comic.id = $(this).find('a').eq(0).attr('href').split('/').filter(Boolean).pop();
    // title
    comic.title = $(this).find('a').eq(0).attr('title');
    // 圖片
    // 圖片有載入是 scr, 未載入前是 data-src
    comic.cover = $(this).find('img').eq(0).attr('src') || $(this).find('img').eq(0).attr('data-src');
    // 更新進度
    comic.note = $(this).find('.tt').eq(0).text();
    // 最後更新時間
    date = $(this).find('em').eq(0).text();
    timestamp = Date.parse(date);
    comic.lastUpdate = (timestamp + length) / 1000
    results.push(comic);
    length--;
});
results;
