import { Router } from "express";

import {
  getUserEvents,
  getUserEventDetail,
  registerEvent,
  checkInEvent,
  getMyEventHistory,
  getCheckinCenter,
} from "../controllers/userEventController";

import {
  authenticateToken,
} from "../middleware/authMiddleware";

const router = Router();

// =============================================================
// ต้อง Login
// =============================================================

router.use(
  authenticateToken
);

// =============================================================
// Static Routes
// ต้องอยู่ก่อน /:id ทั้งหมด
// =============================================================

// GET /api/events
router.get(
  "/",
  getUserEvents
);

// GET /api/events/history
router.get(
  "/history",
  getMyEventHistory
);

// GET /api/events/checkin-center
router.get(
  "/checkin-center",
  getCheckinCenter
);

// =============================================================
// Dynamic Routes
// ต้องอยู่หลัง Static Routes
// =============================================================

// GET /api/events/1
router.get(
  "/:id",
  getUserEventDetail
);

// POST /api/events/1/register
router.post(
  "/:id/register",
  registerEvent
);

// POST /api/events/1/checkin
router.post(
  "/:id/checkin",
  checkInEvent
);

export default router;