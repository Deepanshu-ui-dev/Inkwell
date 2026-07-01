require("dotenv").config();

const express = require("express");
const mongoose = require("mongoose");
const cors = require("cors");
const path = require("path");
const fs = require("fs");

const authRoutes    = require("./routes/auth");
const blogRoutes    = require("./routes/blog");
const uploadRoutes  = require("./routes/upload");
const versionRoutes = require("./routes/version");
const { requireAuth } = require("./middleware/auth");
const { deleteComment } = require("./controllers/blog");

const app  = express();
const PORT = process.env.PORT || 8000;

// ── Ensure uploads dir exists ───────────────────────────────
const uploadsDir = path.join(__dirname, "public/uploads");
if (!fs.existsSync(uploadsDir)) {
  fs.mkdirSync(uploadsDir, { recursive: true });
}

// ── CORS ────────────────────────────────────────────────────
app.use(cors({
  origin: "*",
  methods: ["GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS"],
  allowedHeaders: ["Content-Type", "Authorization"],
}));

// ── Body parsers ────────────────────────────────────────────
app.use(express.json({ limit: "10mb" }));
app.use(express.urlencoded({ extended: true, limit: "10mb" }));

// ── Static files — serve uploads with CORS headers ─────────
// This is the critical part — without proper headers Flutter web
// and CachedNetworkImage will fail to load images.
app.use("/uploads", (req, res, next) => {
  res.setHeader("Access-Control-Allow-Origin", "*");
  res.setHeader("Cross-Origin-Resource-Policy", "cross-origin");
  next();
}, express.static(path.join(__dirname, "public/uploads"), {
  maxAge: "7d",         // cache images for 7 days
  etag: true,
  lastModified: true,
}));

// ── Routes ──────────────────────────────────────────────────
app.get("/", (req, res) => res.json({
  message: "Scribo Blog API 🚀",
  version: "1.0.0",
  uptime: Math.floor(process.uptime()),
  status: "healthy",
}));

app.get("/api/health", (req, res) => res.json({
  status: "ok",
  uptime: Math.floor(process.uptime()),
  timestamp: new Date().toISOString(),
  database: mongoose.connection.readyState === 1 ? "connected" : "disconnected",
}));

app.use("/api/auth",    authRoutes);
app.use("/api/blogs",   blogRoutes);
app.use("/api/upload",  uploadRoutes);
app.use("/api/version", versionRoutes);

app.delete("/api/comments/:id", requireAuth, deleteComment);

// ── 404 ─────────────────────────────────────────────────────
app.use((req, res) => {
  res.status(404).json({ error: `Route ${req.method} ${req.path} not found` });
});

// ── Global error handler ────────────────────────────────────
app.use((err, req, res, next) => {
  console.error("Unhandled error:", err);
  res.status(err.status || 500).json({ error: err.message || "Internal server error" });
});

// ── Start ────────────────────────────────────────────────────
mongoose
  .connect(process.env.MONGO_URI, { dbName: "blog_app_db" })
  .then(() => {
    console.log("✅ MongoDB connected");
    app.listen(PORT, () => {
      console.log(`🚀 Server running on http://localhost:${PORT}`);
      console.log(`📁 Uploads served from http://localhost:${PORT}/uploads/`);
    });
  })
  .catch((err) => {
    console.error("❌ MongoDB connection failed:", err.message);
    process.exit(1);
  });