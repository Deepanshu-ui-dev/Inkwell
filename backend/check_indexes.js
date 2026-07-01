const mongoose = require("mongoose");
require("dotenv").config();
const User = require("./models/user");

async function check() {
  await mongoose.connect(process.env.MONGO_URI);
  const indexes = await User.collection.indexes();
  console.log(indexes);
  mongoose.connection.close();
}
check();
