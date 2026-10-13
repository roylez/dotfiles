// set theme
settings.theme = `
.sk_theme {
    font-family: Input Sans Condensed, Charcoal, sans-serif;
    font-size: 10pt;
    background: #24272e;
    color: #abb2bf;
}
.sk_theme tbody {
    color: #fff;
}
.sk_theme input {
    color: #d0d0d0;
}
.sk_theme .url {
    color: #61afef;
}
.sk_theme .annotation {
    color: #56b6c2;
}
.sk_theme .omnibar_highlight {
    color: #528bff;
}
.sk_theme .omnibar_timestamp {
    color: #e5c07b;
}
.sk_theme .omnibar_visitcount {
    color: #98c379;
}
.sk_theme #sk_omnibarSearchResult ul li:nth-child(odd) {
    background: #303030;
}
.sk_theme #sk_omnibarSearchResult ul li.focused {
    background: #3e4452;
}
#sk_status, #sk_find {
    font-size: 20pt;
}`;

// vimium compatibility layer
api.map('u', 'e');
api.mapkey('p', "Open the clipboard's URL in the current tab", function() {
    api.Clipboard.read(function(response) {
        window.location.href = response.data.trim();
    });
});
api.map('P', 'cc');
api.mapkey('<Alt-p>', '#0enter ephemeral PassThrough mode to temporarily suppress SurfingKeys', function() {
    Normal.passThrough(1500);
});
api.map('gi', 'i');
// af dispatches a synthetic ctrl+shift+click, which Vivaldi binds to
// "open in new window". Open the URL via the background instead.
api.mapkey('F', 'Open a link in a new tab', function() {
    api.Hints.create("", function(element) {
        var link = element.closest && element.closest('a[href]');
        if (link) {
            api.RUNTIME('openLink', {url: link.href, tab: {tabbed: true, active: true}});
        } else {
            api.Hints.dispatchMouseClick(element);
        }
    });
});
api.map('gf', 'w');
api.map('`', "'");
api.map('H', 'S');
api.map('L', 'D');
api.map('gt', 'R');
api.map('gT', 'E');
api.map('K', 'R');
api.map('J', 'E');

// exclusions (from Vimium exclusionRules)
settings.blocklistPattern = /mail\.google\.com|vivaldi\.com\/games|10\.10\.10\.2:8006|pve\.roylez\.info|tiger\.roylez\.info|calendar\.google\.com|global\.americanexpress\.com|thetypingcat\.com|coderpad\.io|screen-ide\.coderpad\.io|nerdvm\.racknerd\.com|www\.lofi\.cafe|vps\.roylez\.info|www\.keybr\.com|nas\.roylez\.info\/webterminal|jd\.roylez\.info|gamepad-tester\.net|academy\.canonical\.com|dos\.zone/i;
settings.grabBackFocus = true;

var post_selector='article, .post, .message, .comment, .message-body, #postlist > div[id^="post_"]'

// [[ / ]] -> previous / next forum post, centered in viewport
function jumpPost(step) {
    var posts = Array.prototype.slice.call(document.querySelectorAll(post_selector));
    if (!posts.length) {
        return;
    }
    var current = document.activeElement && document.activeElement.closest
        ? document.activeElement.closest(post_selector)
        : null;
    var pos = posts.indexOf(current);
    var idx = pos === -1
        ? (step > 0 ? 0 : posts.length - 1)
        : (pos + step + posts.length) % posts.length;
    var target = posts[idx];
    target.setAttribute('tabindex', '-1');
    target.focus({preventScroll: true});
    target.scrollIntoView({behavior: 'smooth', block: 'center'});
}

// page nav: move the built-in [[ / ]] handlers onto [<Space> / ]<Space>.
// api.map copies whatever handler [[ / ]] currently hold, so this must run
// BEFORE the post mappings below. The snippet is re-evaluated on every
// settings broadcast, and by then [[ / ]] hold the post handler -- the guard
// keeps the capture to the first evaluation.
if (!window.__skPostNav) {
    window.__skPostNav = true;
    api.map('[<Space>', '[[', null, 'Click on the previous link on current page');
    api.map(']<Space>', ']]', null, 'Click on the next link on current page');
}

// post nav: [[ / ]] now step through posts
api.mapkey('[[', 'Go to previous forum post', function() {
    jumpPost(-1);
});

api.mapkey(']]', 'Go to next forum post', function() {
    jumpPost(1);
});
