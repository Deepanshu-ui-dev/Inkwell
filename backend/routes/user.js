const express = require("express");
const { handleUserSignUp, handleUserLogin } = require("../controllers/user");
const router = express.Router();


router.get("/signup",(req,res)=>{
    return res.render("signup");
});
router.get("/login",(req,res)=>{
    return res.render("login");
});

router.post("/signup", handleUserSignUp);
router.post("/login", handleUserLogin);

module.exports = router;