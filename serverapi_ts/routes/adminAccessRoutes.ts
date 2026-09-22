import {
  Router,
} from "express";

import {
  getAccessAccounts,
  createAdmin,
  changeUserRole,
} from "../controllers/adminAccessController";

import {
  authenticateToken,
  requireSuperAdmin,
} from "../middleware/authMiddleware";

const router =
  Router();

router.use(
  authenticateToken
);

router.use(
  requireSuperAdmin
);

// GET /api/admin/access
router.get(
  "/",
  getAccessAccounts
);

// POST /api/admin/access/admins
router.post(
  "/admins",
  createAdmin
);

// PATCH /api/admin/access/5/role
router.patch(
  "/:id/role",
  changeUserRole
);

export default router;