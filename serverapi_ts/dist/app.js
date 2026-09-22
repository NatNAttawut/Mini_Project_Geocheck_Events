"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = __importDefault(require("express"));
const cors_1 = __importDefault(require("cors"));
const authRoutes_1 = __importDefault(require("./routes/authRoutes"));
const adminUserRoutes_1 = __importDefault(require("./routes/adminUserRoutes"));
const adminEventRoutes_1 = __importDefault(require("./routes/adminEventRoutes"));
const app = (0, express_1.default)();
// Middleware
app.use((0, cors_1.default)());
app.use(express_1.default.json());
app.use(express_1.default.urlencoded({
    extended: true,
}));
// ============================================================
// Routes
// ============================================================
app.use("/api/auth", authRoutes_1.default);
app.use("/api/admin/users", adminUserRoutes_1.default);
app.use("/api/admin/events", adminEventRoutes_1.default);
// ============================================================
// Test API
// ============================================================
app.get("/", (req, res) => {
    res.json({
        status: "success",
        message: "GeoCheck Event API is running",
    });
});
exports.default = app;
