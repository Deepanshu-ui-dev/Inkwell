const mongoose = require("mongoose");
require("dotenv").config();

async function check() {
  await mongoose.connect(process.env.MONGO_URI);
  console.log("DB Name:", mongoose.connection.name);
  
  const User = mongoose.model("User");
  const indexes = await User.collection.indexes();
  console.log("Indexes in", User.collection.namespace, ":", indexes);
  
  mongoose.connection.close();
}
check();
