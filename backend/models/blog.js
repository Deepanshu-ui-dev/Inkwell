const mongoose = require("mongoose");

const blogSchema = new mongoose.Schema(
  {
    title: {
      type: String,
      required: [true, "Title is required"],
      trim: true,
      maxlength: [200, "Title cannot exceed 200 characters"],
    },

    content: {
      type: String,
      required: [true, "Content is required"],
    },

    author: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      required: true,
    },

    coverImage: {
      type: String,
      default: null,
    },

    tags: {
      type: [String],
      default: [],
    },

    // Array of User IDs who liked this post
    likes: {
      type: [{ type: mongoose.Schema.Types.ObjectId, ref: "User" }],
      default: [],
    },

    isPublished: {
      type: Boolean,
      default: true,
    },

    readTime: {
      type: Number, // minutes
      default: 1,
    },
  },
  { timestamps: true }
);

// Virtual: likes count
blogSchema.virtual("likesCount").get(function () {
  return this.likes.length;
});

blogSchema.set("toJSON", { virtuals: true });
blogSchema.set("toObject", { virtuals: true });

const Blog = mongoose.model("Blog", blogSchema);
module.exports = Blog;
