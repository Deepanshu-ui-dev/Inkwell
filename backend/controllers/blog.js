const Blog = require("../models/blog");
const Comment = require("../models/comment");

// ── Blogs ────────────────────────────────────────────────────────────────────

/** GET /api/blogs — paginated list of published blogs */
async function getBlogs(req, res) {
  try {
    const page = Math.max(1, parseInt(req.query.page) || 1);
    const limit = Math.min(50, parseInt(req.query.limit) || 10);
    const skip = (page - 1) * limit;

    const blogs = await Blog.find({ isPublished: true })
      .populate("author", "fullname avatarUrl")
      .sort({ createdAt: -1 })
      .skip(skip)
      .limit(limit)
      .lean({ virtuals: true });

    // Rename fullname → name for Flutter model compatibility
    const formatted = blogs.map(formatBlog);
    return res.status(200).json({ blogs: formatted, page, limit });
  } catch (err) {
    console.error("getBlogs error:", err);
    return res.status(500).json({ error: "Internal server error" });
  }
}

/** GET /api/blogs/:id */
async function getBlog(req, res) {
  try {
    const blog = await Blog.findById(req.params.id)
      .populate("author", "fullname avatarUrl")
      .lean({ virtuals: true });

    if (!blog) return res.status(404).json({ error: "Blog not found" });
    return res.status(200).json({ blog: formatBlog(blog) });
  } catch (err) {
    return res.status(500).json({ error: "Internal server error" });
  }
}

/** POST /api/blogs — create (auth required) */
async function createBlog(req, res) {
  try {
    const { title, content, coverImage, tags, isPublished } = req.body;
    if (!title || !content) {
      return res.status(400).json({ error: "title and content are required" });
    }

    // Estimate read time (~200 words per minute)
    const words = content.trim().split(/\s+/).length;
    const readTime = Math.max(1, Math.round(words / 200));

    const blog = await Blog.create({
      title,
      content,
      coverImage: coverImage || null,
      tags: tags || [],
      isPublished: isPublished !== undefined ? isPublished : true,
      readTime,
      author: req.user._id,
    });

    await blog.populate("author", "fullname avatarUrl");
    return res.status(201).json({ blog: formatBlog(blog.toObject({ virtuals: true })) });
  } catch (err) {
    console.error("createBlog error:", err);
    return res.status(500).json({ error: "Internal server error" });
  }
}

/** PUT /api/blogs/:id — update (auth required, must be author) */
async function updateBlog(req, res) {
  try {
    const blog = await Blog.findById(req.params.id);
    if (!blog) return res.status(404).json({ error: "Blog not found" });
    if (blog.author.toString() !== req.user._id.toString()) {
      return res.status(403).json({ error: "Forbidden — not the author" });
    }

    const { title, content, coverImage, tags, isPublished } = req.body;
    if (title) blog.title = title;
    if (content) {
      blog.content = content;
      const words = content.trim().split(/\s+/).length;
      blog.readTime = Math.max(1, Math.round(words / 200));
    }
    if (coverImage !== undefined) blog.coverImage = coverImage;
    if (tags) blog.tags = tags;
    if (isPublished !== undefined) blog.isPublished = isPublished;

    await blog.save();
    await blog.populate("author", "fullname avatarUrl");
    return res.status(200).json({ blog: formatBlog(blog.toObject({ virtuals: true })) });
  } catch (err) {
    return res.status(500).json({ error: "Internal server error" });
  }
}

/** DELETE /api/blogs/:id */
async function deleteBlog(req, res) {
  try {
    const blog = await Blog.findById(req.params.id);
    if (!blog) return res.status(404).json({ error: "Blog not found" });
    if (blog.author.toString() !== req.user._id.toString()) {
      return res.status(403).json({ error: "Forbidden — not the author" });
    }
    await Blog.findByIdAndDelete(req.params.id);
    await Comment.deleteMany({ blog: req.params.id });
    return res.status(200).json({ message: "Blog deleted" });
  } catch (err) {
    return res.status(500).json({ error: "Internal server error" });
  }
}

// ── Likes ─────────────────────────────────────────────────────────────────────

/** POST /api/blogs/:id/like — toggle like (auth required) */
async function toggleLike(req, res) {
  try {
    const blog = await Blog.findById(req.params.id);
    if (!blog) return res.status(404).json({ error: "Blog not found" });

    const userId = req.user._id.toString();
    const idx = blog.likes.findIndex((id) => id.toString() === userId);

    let liked;
    if (idx === -1) {
      blog.likes.push(req.user._id);
      liked = true;
    } else {
      blog.likes.splice(idx, 1);
      liked = false;
    }

    await blog.save();
    return res.status(200).json({ liked, likesCount: blog.likes.length });
  } catch (err) {
    return res.status(500).json({ error: "Internal server error" });
  }
}

/** GET /api/blogs/:id/like-status (auth required) */
async function getLikeStatus(req, res) {
  try {
    const blog = await Blog.findById(req.params.id).select("likes").lean();
    if (!blog) return res.status(404).json({ error: "Blog not found" });
    const liked = blog.likes.some((id) => id.toString() === req.user._id.toString());
    return res.status(200).json({ liked });
  } catch (err) {
    return res.status(500).json({ error: "Internal server error" });
  }
}

// ── Comments ──────────────────────────────────────────────────────────────────

/** GET /api/blogs/:id/comments (public) */
async function getComments(req, res) {
  try {
    const comments = await Comment.find({ blog: req.params.id })
      .populate("author", "fullname avatarUrl")
      .sort({ createdAt: -1 })
      .lean();

    const formatted = comments.map(formatComment);
    return res.status(200).json({ comments: formatted });
  } catch (err) {
    return res.status(500).json({ error: "Internal server error" });
  }
}

/** POST /api/blogs/:id/comments (auth required) */
async function postComment(req, res) {
  try {
    const { text } = req.body;
    if (!text || !text.trim()) {
      return res.status(400).json({ error: "Comment text is required" });
    }

    const blog = await Blog.findById(req.params.id);
    if (!blog) return res.status(404).json({ error: "Blog not found" });

    const comment = await Comment.create({
      blog: req.params.id,
      author: req.user._id,
      text: text.trim(),
    });
    await comment.populate("author", "fullname avatarUrl");
    return res.status(201).json({ comment: formatComment(comment.toObject()) });
  } catch (err) {
    return res.status(500).json({ error: "Internal server error" });
  }
}

/** DELETE /api/comments/:id (auth required, own comment) */
async function deleteComment(req, res) {
  try {
    const comment = await Comment.findById(req.params.id);
    if (!comment) return res.status(404).json({ error: "Comment not found" });
    if (comment.author.toString() !== req.user._id.toString()) {
      return res.status(403).json({ error: "Forbidden — not your comment" });
    }
    await Comment.findByIdAndDelete(req.params.id);
    return res.status(200).json({ message: "Comment deleted" });
  } catch (err) {
    return res.status(500).json({ error: "Internal server error" });
  }
}

// ── Formatters ────────────────────────────────────────────────────────────────

function formatBlog(blog) {
  return {
    _id: blog._id,
    title: blog.title,
    content: blog.content,
    coverImageUrl: blog.coverImage,   // Flutter model uses coverImageUrl
    tags: blog.tags,
    published: blog.isPublished,       // Flutter model uses published
    readTime: blog.readTime,
    likesCount: (blog.likes || []).length,
    likedBy: (blog.likes || []).map((id) => id.toString()), // Flutter uses likedBy array
    author: blog.author
      ? {
          _id: blog.author._id,
          name: blog.author.fullname,
          avatarUrl: blog.author.avatarUrl,
        }
      : null,
    createdAt: blog.createdAt,
    updatedAt: blog.updatedAt,
  };
}

function formatComment(comment) {
  return {
    _id: comment._id,
    blog: comment.blog,
    text: comment.text,
    viewer: comment.author          // Flutter CommentModel uses 'viewer' key
      ? {
          _id: comment.author._id,
          name: comment.author.fullname,
          avatarUrl: comment.author.avatarUrl,
        }
      : null,
    createdAt: comment.createdAt,
  };
}

module.exports = {
  getBlogs,
  getBlog,
  createBlog,
  updateBlog,
  deleteBlog,
  toggleLike,
  getLikeStatus,
  getComments,
  postComment,
  deleteComment,
};
