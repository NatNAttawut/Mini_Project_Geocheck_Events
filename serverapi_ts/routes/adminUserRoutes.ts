import { Router } from "express";

import {
  getUsers,
  createUser,
  updateUser,
  deleteUser,
} from "../controllers/adminUserController";
import { authenticateToken } from "../middleware/authMiddleware";
import { adminMiddleware } from "../middleware/adminMiddleware";

const router = Router();

// ทุก API ด้านล่าง
// ต้อง Login และต้องเป็น Admin
router.use(authenticateToken);
router.use(adminMiddleware);

router.get("/", getUsers);

router.post("/", createUser);

router.put("/:id", updateUser);

router.delete("/:id", deleteUser);

export default router;