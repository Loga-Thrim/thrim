const express = require("express");
const app = express();
const mongoose = require('mongoose');

main().catch(err => console.log(err));

async function main() {
  await mongoose.connect('mongodb://localhost:27017/thrim');
}

const port = process.env.PORT || 5000;

const router = require("./src/view/router");

router(app, mongoose);

app.listen(port, () => console.log(`> App on port ${port}`));
