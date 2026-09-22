import { Router } from "express";

import {
  getReportSummary,
} from "../controllers/adminReportController";

import {
  authenticateToken,
} from "../middleware/authMiddleware";

import {
  adminMiddleware,
} from "../middleware/adminMiddleware";

const router = Router();

// ต้อง Login
router.use(
  authenticateToken
);

// ต้องเป็น Admin
router.use(
  adminMiddleware
);

router.get(
  "/summary",
  getReportSummary
);

export default router;