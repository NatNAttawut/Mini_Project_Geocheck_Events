import { Router } from "express";

import {
  getEvents,
  getEventDetail,
  createEvent,
  updateEvent,
  deleteEvent,
} from "../controllers/adminEventController";

import {
  authenticateToken,
} from "../middleware/authMiddleware";

import {
  adminMiddleware,
} from "../middleware/adminMiddleware";

const router =
  Router();

// ทุก Route ต้อง Login ก่อน
router.use(
  authenticateToken
);

// และต้องเป็น Admin
router.use(
  adminMiddleware
);

router.get(
  "/",
  getEvents
);

router.get(
  "/:id/detail",
  getEventDetail
);

router.post(
  "/",
  createEvent
);

router.put(
  "/:id",
  updateEvent
);

router.delete(
  "/:id",
  deleteEvent
);

export default router;