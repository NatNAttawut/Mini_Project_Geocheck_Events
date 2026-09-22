import { Router } from "express";

import {
  getUserHome,
} from "../controllers/userHomeController";

import {
  authenticateToken,
} from "../middleware/authMiddleware";

const router = Router();

router.use(
  authenticateToken
);

router.get(
  "/",
  getUserHome
);

export default router;