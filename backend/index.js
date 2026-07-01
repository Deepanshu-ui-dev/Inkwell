require("dotenv").config();

const express = require("express");
const mongoose = require("mongoose");
const cors = require("cors");

const authRoutes = require("./routes/auth");
const blogRoutes = require("./routes/blog");
const uploadRoutes = require("./routes/upload");
const versionRoutes = require("./routes/version");
const { requireAuth } = require("./middleware/auth");
const { deleteComment } = require("./controllers/blog");
const path = require("path");

const app = express();
const PORT = process.env.PORT || 8000;

// ── Middleware ──────────────────────────────────────────────
app.use(cors({
  origin: "*",
  methods: ["GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS"],
  allowedHeaders: ["Content-Type", "Authorization"],
}));
app.use(express.json({ limit: "10mb" }));
app.use(express.urlencoded({ extended: true, limit: "10mb" }));

// Serve static files from public directory
app.use("/uploads", express.static(path.join(__dirname, "public/uploads")));

// ── Routes ──────────────────────────────────────────────────
app.get("/", (req, res) => res.json({
  message: "Scribo Blog API 🚀",
  version: "1.0.0",
  uptime: Math.floor(process.uptime()),
  status: "healthy",
}));

// Health check endpoint
app.get("/api/health", (req, res) => res.json({
  status: "ok",
  uptime: Math.floor(process.uptime()),
  timestamp: new Date().toISOString(),
  database: mongoose.connection.readyState === 1 ? "connected" : "disconnected",
}));

app.use("/api/auth", authRoutes);
app.use("/api/blogs", blogRoutes);
app.use("/api/upload", uploadRoutes);
app.use("/api/version", versionRoutes);

// Delete comment lives outside /blogs because the frontend calls DELETE /comments/:id
app.delete("/api/comments/:id", requireAuth, deleteComment);


// ── 404 handler ─────────────────────────────────────────────
app.use((req, res) => {
  res.status(404).json({ error: `Route ${req.method} ${req.path} not found` });
});

// ── Global error handler ────────────────────────────────────
app.use((err, req, res, next) => {
  console.error("Unhandled error:", err);
  res.status(500).json({ error: "Internal server error" });
});

// ── Connect to MongoDB, then start server ───────────────────
mongoose
  .connect(process.env.MONGO_URI, { dbName: "blog_app_db" })
  .then(() => {
    console.log("✅ MongoDB connected");
    app.listen(PORT, () => console.log(`🚀 Server running on port ${PORT}`));
  })
  .catch((err) => {
    console.error("❌ MongoDB connection failed:", err.message);
    process.exit(1);
  });