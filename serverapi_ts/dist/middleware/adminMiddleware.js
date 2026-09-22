"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.adminMiddleware = void 0;
const adminMiddleware = (req, res, next) => {
    const user = req.user;
    if (!user) {
        return res.status(401).json({
            success: false,
            message: "กรุณาเข้าสู่ระบบ",
        });
    }
    if (user.role !== "admin") {
        return res.status(403).json({
            success: false,
            message: "คุณไม่มีสิทธิ์ใช้งานส่วนนี้",
        });
    }
    next();
};
exports.adminMiddleware = adminMiddleware;
