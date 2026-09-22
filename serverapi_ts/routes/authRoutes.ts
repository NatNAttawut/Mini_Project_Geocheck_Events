import { Router } from "express";

import {
  register,
  login,
} from "../controllers/authController";

import {
  authenticateToken,
  AuthRequest,
} from "../middleware/authMiddleware";

const router = Router();

// สมัครสมาชิก
router.post(
  "/register",
  register
);

// เข้าสู่ระบบ
router.post(
  "/login",
  login
);

// ทดสอบ JWT
router.get(
  "/me",
  authenticateToken,
  (req: AuthRequest, res) => {
    res.status(200).json({
      success: true,
      message: "JWT ใช้งานได้",
      user: req.user,
    });
  }
);

export default router;