var results = [];
var list = $('.latest-list > ul > li');

list.each(function() {
    var comic = new Object();
    comic.title = $(this).find('a').eq(0).attr('title');
    comic.detailPath = $(this).find('a').eq(0).attr('href');
    // 圖片有載入是 scr, 未載入前是 data-src
    comic.imageURI = $(this).find('img').eq(0).attr('src') || $(this).find('img').eq(0).attr('data-src');
    comic.episode = $(this).find('.tt').eq(0).text();
    //comic.update = $(this).find('em').eq(0).text();
    results.push(comic);
});
results;
