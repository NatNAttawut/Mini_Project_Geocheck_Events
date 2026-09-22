"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.authenticateToken = void 0;
const jsonwebtoken_1 = __importDefault(require("jsonwebtoken"));
const JWT_SECRET = process.env.JWT_SECRET || "geocheck_default_secret";
const authenticateToken = (req, res, next) => {
    // Authorization: Bearer TOKEN
    const authHeader = req.headers.authorization;
    if (!authHeader) {
        res.status(401).json({
            success: false,
            message: "ไม่พบ Token",
        });
        return;
    }
    const parts = authHeader.split(" ");
    if (parts.length !== 2 ||
        parts[0] !== "Bearer") {
        res.status(401).json({
            success: false,
            message: "รูปแบบ Token ไม่ถูกต้อง",
        });
        return;
    }
    const token = parts[1];
    try {
        const decoded = jsonwebtoken_1.default.verify(token, JWT_SECRET);
        req.user = {
            id: decoded.id,
            email: decoded.email,
            role: decoded.role,
        };
        next();
    }
    catch (error) {
        res.status(401).json({
            success: false,
            message: "Token ไม่ถูกต้องหรือหมดอายุ",
        });
    }
};
exports.authenticateToken = authenticateToken;
