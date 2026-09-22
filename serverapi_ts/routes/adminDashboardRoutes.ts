import { Router } from "express";

import {
  getDashboard,
} from "../controllers/adminDashboardController";

import {
  authenticateToken,
} from "../middleware/authMiddleware";

import {
  adminMiddleware,
} from "../middleware/adminMiddleware";

const router = Router();

router.use(authenticateToken);
router.use(adminMiddleware);

router.get(
  "/",
  getDashboard
);

export default router;