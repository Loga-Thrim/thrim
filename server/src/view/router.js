const cors = require("cors");
const bodyParser = require("body-parser");

const { get, post, isLike } = require("../components/post");

module.exports = function (app, mongoose) {
  app
    .use(cors())
    .use(bodyParser.json())
    .use(bodyParser.urlencoded())

    .get("/post/:userId", (req, res) => get(req, res, mongoose))
    .post('/post', (req, res) => post(req, res, mongoose))
    .put('/post/is-like', (req, res) => isLike(req, res, mongoose))
};
