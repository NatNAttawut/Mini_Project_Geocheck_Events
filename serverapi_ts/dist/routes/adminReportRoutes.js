"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const adminReportController_1 = require("../controllers/adminReportController");
const authMiddleware_1 = require("../middleware/authMiddleware");
const adminMiddleware_1 = require("../middleware/adminMiddleware");
const router = (0, express_1.Router)();
// ต้อง Login
router.use(authMiddleware_1.authMiddleware);
// ต้องเป็น Admin
router.use(adminMiddleware_1.adminMiddleware);
router.get("/summary", adminReportController_1.getReportSummary);
exports.default = router;
