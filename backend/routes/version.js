const express = require("express");
const router = express.Router();

// ── App Version Config ───────────────────────────────────────────
// Bump these values when you release a new build.
// minVersion: oldest version the app will allow to run without forcing update.
// currentVersion: the latest released version.
const VERSION_CONFIG = {
  currentVersion: "1.0.0",
  minVersion: "1.0.0",
  forceUpgrade: false,
  changelog: "Welcome to Scribo! Read, write, and react to stories.",
  storeUrl: {
    android: "https://play.google.com/store/apps/details?id=com.example.scribo",
    ios: "https://apps.apple.com/app/scribo/id000000000",
    web: null,
  },
  buildNumber: 1,
  releaseDate: "2026-07-01",
};

/**
 * GET /api/version
 * Returns version metadata for OTA update checks.
 *
 * Flutter client should call this on app launch and compare
 * the returned minVersion/currentVersion against its own version
 * from pubspec.yaml (package_info_plus).
 *
 * Response:
 * {
 *   "currentVersion": "1.0.0",       // latest available
 *   "minVersion": "1.0.0",           // minimum supported; older = force upgrade
 *   "forceUpgrade": false,           // explicit override flag
 *   "changelog": "...",              // what's new in currentVersion
 *   "storeUrl": { "android": "...", "ios": "..." },
 *   "buildNumber": 1,
 *   "releaseDate": "2026-07-01"
 * }
 */
router.get("/", (req, res) => {
  res.json({
    success: true,
    ...VERSION_CONFIG,
    serverTime: new Date().toISOString(),
  });
});

module.exports = router;
