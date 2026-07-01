const mongoose = require("mongoose");
require("dotenv").config();
const User = require("./models/user");

async function run() {
  await mongoose.connect(process.env.MONGO_URI);
  const users = await User.find({}, 'email fullname salt role');
  console.log("Users:", users);
  mongoose.connection.close();
}
run();
