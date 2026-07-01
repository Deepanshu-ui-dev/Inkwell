const express = require("express");
const {
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
} = require("../controllers/blog");
const { requireAuth } = require("../middleware/auth");

const router = express.Router();

// ── Blog CRUD ──────────────────────────────────────────────
router.get("/", getBlogs);                          // public
router.get("/:id", getBlog);                        // public
router.post("/", requireAuth, createBlog);          // auth
router.put("/:id", requireAuth, updateBlog);        // auth
router.delete("/:id", requireAuth, deleteBlog);     // auth

// ── Likes ──────────────────────────────────────────────────
router.post("/:id/like", requireAuth, toggleLike);
router.get("/:id/like-status", requireAuth, getLikeStatus);

// ── Comments ───────────────────────────────────────────────
router.get("/:id/comments", getComments);                   // public
router.post("/:id/comments", requireAuth, postComment);     // auth

// Note: delete comment is handled at /api/comments/:id (see index.js)

module.exports = router;
