// 成人遮罩
$('#checkAdult').click();
var detail = new Object();
detail.author = $('.cont-list').find('dd').eq(2).text();
detail.desc = $('#bookIntro p').text()
var episodes = [];
$('.chapter-list li').each(function(idx, element) {
    var episode = new Object();
    episode.title = $(element).find('b').eq(0).text();
    episode.path = $(element).find('a').eq(0).attr('href');
    episodes.push(episode);
});
detail.episodes = episodes;
detail;
