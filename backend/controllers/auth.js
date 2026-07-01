const { createHmac, randomBytes } = require("crypto");
const jwt = require("jsonwebtoken");
const User = require("../models/user");
const { OAuth2Client } = require("google-auth-library");

const client = new OAuth2Client(); // Client ID will be passed during verifyIdToken if available

// ── Helper ──────────────────────────────────────────────────────────────────

function signToken(userId) {
  return jwt.sign({ id: userId }, process.env.JWT_SECRET, {
    expiresIn: process.env.JWT_EXPIRES_IN || "7d",
  });
}

function hashPassword(salt, password) {
  return createHmac("sha512", salt).update(password).digest("hex");
}

function formatUser(user) {
  return {
    _id: user._id,
    name: user.fullname,
    email: user.email,
    role: user.role.toLowerCase(), // "USER" → "user" for frontend compatibility
    avatarUrl: user.avatarUrl,
    createdAt: user.createdAt,
  };
}

// ── Signup ──────────────────────────────────────────────────────────────────

async function handleUserSignUp(req, res) {
  try {
    const { name, email, password } = req.body;

    if (!name || !email || !password) {
      return res.status(400).json({ error: "name, email and password are required" });
    }

    const existing = await User.findOne({ email: email.toLowerCase().trim() });
    if (existing) {
      return res.status(409).json({ error: "An account with this email already exists" });
    }

    // User model pre-save hook hashes the password automatically
    const user = await User.create({ fullname: name, email, password });

    const token = signToken(user._id);
    return res.status(201).json({ user: formatUser(user), token });
  } catch (err) {
    console.error("Signup error:", err);
    if (err.code === 11000) {
      return res.status(409).json({ error: "Email already in use", details: err.message });
    }
    return res.status(500).json({ error: "Internal server error", details: err.message });
  }
}

// ── Login ───────────────────────────────────────────────────────────────────

async function handleUserLogin(req, res) {
  try {
    const { email, password } = req.body;

    if (!email || !password) {
      return res.status(400).json({ error: "email and password are required" });
    }

    const user = await User.findOne({ email: email.toLowerCase().trim() });
    if (!user) {
      return res.status(401).json({ error: "Invalid email or password" });
    }

    // Re-hash submitted password with the stored salt and compare
    const hashed = hashPassword(user.salt, password);
    if (hashed !== user.password) {
      return res.status(401).json({ error: "Invalid email or password" });
    }

    const token = signToken(user._id);
    return res.status(200).json({ user: formatUser(user), token });
  } catch (err) {
    console.error("Login error:", err);
    return res.status(500).json({ error: "Internal server error" });
  }
}

// ── Get Me (protected) ───────────────────────────────────────────────────────

async function handleGetMe(req, res) {
  // req.user is attached by the requireAuth middleware
  return res.status(200).json({ user: formatUser(req.user) });
}

// ── Google Auth ─────────────────────────────────────────────────────────────

async function handleGoogleAuth(req, res) {
  try {
    const { idToken } = req.body;
    if (!idToken) return res.status(400).json({ error: "idToken is required" });

    // In a real production app, you MUST verify the token audience matches your client ID.
    // If GOOGLE_CLIENT_ID is set in .env, we verify it. Otherwise, we just decode it (INSECURE - for dev only).
    let payload;
    if (process.env.GOOGLE_CLIENT_ID) {
      const ticket = await client.verifyIdToken({
        idToken,
        audience: process.env.GOOGLE_CLIENT_ID,
      });
      payload = ticket.getPayload();
    } else {
      // INSECURE fallback for dev when Client ID is not yet configured
      const jwtDecoded = jwt.decode(idToken);
      if (!jwtDecoded) throw new Error("Invalid ID token");
      payload = jwtDecoded;
    }

    const { email, name, picture } = payload;
    if (!email) return res.status(400).json({ error: "Google token missing email" });

    let user = await User.findOne({ email: email.toLowerCase().trim() });
    
    if (!user) {
      // Create new user, bypass password requirement with a random secure string
      const randomPassword = randomBytes(16).toString("hex");
      user = await User.create({
        fullname: name || "Google User",
        email: email.toLowerCase().trim(),
        password: randomPassword,
        avatarUrl: picture || "https://cdn-icons-png.flaticon.com/512/149/149071.png",
      });
    }

    const token = signToken(user._id);
    return res.status(200).json({ user: formatUser(user), token });
  } catch (err) {
    console.error("Google Auth error:", err);
    return res.status(500).json({ error: "Failed to authenticate with Google" });
  }
}

module.exports = { handleUserSignUp, handleUserLogin, handleGetMe, handleGoogleAuth };