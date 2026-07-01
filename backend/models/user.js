const mongoose = require("mongoose");
const { createHmac, randomBytes } = require("crypto");

const userSchema = new mongoose.Schema(
  {
    fullname: {
      type: String,
      required: [true, "Full name is required"],
      trim: true,
    },

    email: {
      type: String,
      required: [true, "Email is required"],
      unique: true,
      lowercase: true,
      trim: true,
      validate: {
        validator: function (value) {
          return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(value);
        },
        message: "Please enter a valid email.",
      },
    },

    salt: {
      type: String,
      default: null,
    },

    // Stored as the SHA-512 hash; minlength removed since the plain value
    // is replaced by a 128-char hex string before validation runs.
    password: {
      type: String,
      required: [true, "Password is required"],
    },

    avatarUrl: {
      type: String,
      default: "https://cdn-icons-png.flaticon.com/512/149/149071.png",
    },

    role: {
      type: String,
      enum: ["USER", "ADMIN"],
      default: "USER",
    },
  },
  {
    timestamps: true,
  }
);

// Async pre-save hook (Mongoose 7+ compatible — no next parameter)
userSchema.pre("save", async function () {
  const user = this;
  if (!user.isModified("password")) return;
  const salt = randomBytes(16).toString("hex");
  const hashedPassword = createHmac("sha512", salt)
    .update(user.password)
    .digest("hex");
  user.salt = salt;
  user.password = hashedPassword;
});

const User = mongoose.model("User", userSchema);

module.exports = User;