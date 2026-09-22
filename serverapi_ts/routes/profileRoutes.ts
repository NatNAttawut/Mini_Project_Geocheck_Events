import { Router } from "express";

import {
  getProfile,
  updateProfile,
  changePassword,
} from "../controllers/profileController";

import {
  authenticateToken,
} from "../middleware/authMiddleware";

const router = Router();

router.use(
  authenticateToken
);

// GET /api/profile
router.get(
  "/",
  getProfile
);

// PUT /api/profile
router.put(
  "/",
  updateProfile
);

// PUT /api/profile/password
router.put(
  "/password",
  changePassword
);

export default router;