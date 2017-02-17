(function() {


function pickRandomProperty(obj) {
    return pickRandomArrayItem(Object.keys(obj));
}

function pickRandomProperty_bak(obj) {
    var result;
    var count = 0;
    for (var prop in obj)
        if (Math.random() < 1/++count)
           result = prop;
    return result;
}

function pickRandomArrayItem(items) {
    var item = items[Math.floor(Math.random()*items.length)];
    return item;
}

function generate(map, num) {
    var out = "";
    var key = pickRandomProperty(map);
    out += key;

    while (num-- > 0) {
        if (!map.hasOwnProperty(key)) {
            key = pickRandomProperty(map);
            out += "<br>\n";
        }

        var n = pickRandomArrayItem(map[key]);
        out += n;
        key = n;
    }

    return out;
}

function fillOutput() {
    var output = generate(map, 300);
    document.getElementById('output').innerHTML = output;
}

setTimeout(function(){ fillOutput(); }, 3000);


})();
