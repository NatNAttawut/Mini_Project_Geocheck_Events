"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const adminEventController_1 = require("../controllers/adminEventController");
const authMiddleware_1 = require("../middleware/authMiddleware");
const adminMiddleware_1 = require("../middleware/adminMiddleware");
const router = (0, express_1.Router)();
// ทุก Route ต้อง Login ก่อน
router.use(authMiddleware_1.authenticateToken);
// และต้องเป็น Admin
router.use(adminMiddleware_1.adminMiddleware);
router.get("/", adminEventController_1.getEvents);
router.post("/", adminEventController_1.createEvent);
router.put("/:id", adminEventController_1.updateEvent);
router.delete("/:id", adminEventController_1.deleteEvent);
exports.default = router;
