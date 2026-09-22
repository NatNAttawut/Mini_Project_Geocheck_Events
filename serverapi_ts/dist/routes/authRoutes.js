"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const authController_1 = require("../controllers/authController");
const authMiddleware_1 = require("../middleware/authMiddleware");
const router = (0, express_1.Router)();
// สมัครสมาชิก
router.post("/register", authController_1.register);
// เข้าสู่ระบบ
router.post("/login", authController_1.login);
// ทดสอบ JWT
router.get("/me", authMiddleware_1.authenticateToken, (req, res) => {
    res.status(200).json({
        success: true,
        message: "JWT ใช้งานได้",
        user: req.user,
    });
});
exports.default = router;
