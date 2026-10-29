const assert = require("node:assert/strict");
const fs = require("node:fs");
const vm = require("node:vm");

const utils = vm.createContext({});
vm.runInContext(fs.readFileSync(`${__dirname}/helpers.js`, "utf8"), utils);

for (const separator of ["\n\n", "\r\n\r\n", "<br/><br/>", "&lt;br&gt;\n"]) {
    assert.equal(utils.render(`web.whatsapp.com${separator}Hello <b>there</b>`), "Hello <b>there</b>");
}
assert.equal(utils.render("example.com\n\nHello"), "example.com<br/><br/>Hello");
assert.equal(utils.render("Visit web.whatsapp.com\nHello"), "Visit web.whatsapp.com<br/>Hello");
assert.equal(utils.render("web.whatsapp.com"), "web.whatsapp.com");
assert.equal(utils.render("https://web.whatsapp.com\nHello"), "https://web.whatsapp.com<br/>Hello");
