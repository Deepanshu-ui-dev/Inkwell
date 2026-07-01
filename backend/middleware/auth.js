const jwt = require("jsonwebtoken");
const User = require("../models/user");

/**
 * Middleware: verifies the Bearer JWT in the Authorization header.
 * Attaches the full user document to req.user on success.
 */
async function requireAuth(req, res, next) {
  const authHeader = req.headers.authorization;
  if (!authHeader || !authHeader.startsWith("Bearer ")) {
    return res.status(401).json({ error: "Unauthorised — no token provided" });
  }

  const token = authHeader.split(" ")[1];
  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    const user = await User.findById(decoded.id).select("-password -salt");
    if (!user) {
      return res.status(401).json({ error: "Unauthorised — user not found" });
    }
    req.user = user;
    next();
  } catch (err) {
    return res.status(401).json({ error: "Unauthorised — invalid or expired token" });
  }
}

module.exports = { requireAuth };
