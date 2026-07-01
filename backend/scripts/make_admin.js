const mongoose = require("mongoose");
require("dotenv").config();
const User = require("../models/user");

async function makeAdmin() {
  const email = process.argv[2];
  if (!email) {
    console.error("Please provide an email address. Usage: node make_admin.js <email>");
    process.exit(1);
  }

  try {
    await mongoose.connect(process.env.MONGO_URI, { dbName: "blog_app_db" });
    console.log("Connected to MongoDB.");

    const user = await User.findOneAndUpdate(
      { email: email.toLowerCase().trim() },
      { role: "ADMIN" },
      { new: true }
    );

    if (user) {
      console.log(`✅ Success! ${user.email} is now an ADMIN.`);
    } else {
      console.log(`❌ User with email ${email} not found.`);
    }
  } catch (err) {
    console.error("Error:", err);
  } finally {
    mongoose.connection.close();
  }
}

makeAdmin();
