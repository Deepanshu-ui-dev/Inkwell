const mongoose = require("mongoose");
require("dotenv").config();
const User = require("../models/user");

async function run() {
  await mongoose.connect(process.env.MONGO_URI, { dbName: "blog_app_db" });
  const users = await User.find({}, 'email fullname role');
  console.log("Users in blog_app_db:", users);
  mongoose.connection.close();
}
run();
