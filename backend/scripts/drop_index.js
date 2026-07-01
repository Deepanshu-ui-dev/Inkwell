const mongoose = require("mongoose");
require("dotenv").config();
const User = require("../models/user");

async function drop() {
  await mongoose.connect(process.env.MONGO_URI);
  try {
    const result = await User.collection.dropIndex("id_1");
    console.log("Index dropped:", result);
  } catch(e) {
    console.log("Error:", e.message);
  }
  
  try {
    const indexes = await User.collection.indexes();
    console.log("Current indexes:", indexes);
  } catch(e) {}
  
  mongoose.connection.close();
}
drop();
