const express = require("express");
const { handleUserSignUp, handleUserLogin, handleGetMe, handleGoogleAuth } = require("../controllers/auth");
const { requireAuth } = require("../middleware/auth");

const router = express.Router();

// Public
router.post("/signup", handleUserSignUp);
router.post("/login", handleUserLogin);
router.post("/google", handleGoogleAuth);

// Protected
router.get("/me", requireAuth, handleGetMe);

module.exports = router;
