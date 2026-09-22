"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const adminUserController_1 = require("../controllers/adminUserController");
const authMiddleware_1 = require("../middleware/authMiddleware");
const adminMiddleware_1 = require("../middleware/adminMiddleware");
const router = (0, express_1.Router)();
// ทุก API ด้านล่าง
// ต้อง Login และต้องเป็น Admin
router.use(authMiddleware_1.authenticateToken);
router.use(adminMiddleware_1.adminMiddleware);
router.get("/", adminUserController_1.getUsers);
router.post("/", adminUserController_1.createUser);
router.put("/:id", adminUserController_1.updateUser);
router.delete("/:id", adminUserController_1.deleteUser);
exports.default = router;
