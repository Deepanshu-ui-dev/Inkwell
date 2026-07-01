const mongoose = require("mongoose");
require("dotenv").config();
const User = require("./models/user");

async function check() {
  await mongoose.connect(process.env.MONGO_URI);
  try {
    const user = await User.create({ fullname: "Test", email: "random123456789@example.com", password: "password" });
    console.log(user);
  } catch (err) {
    console.error(err);
  }
  mongoose.connection.close();
}
check();
