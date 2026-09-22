"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const dotenv_1 = __importDefault(require("dotenv"));
const app_1 = __importDefault(require("./app"));
const db_1 = __importDefault(require("./utils/db"));
dotenv_1.default.config();
const PORT = process.env.PORT || 3000;
async function startServer() {
    try {
        // ทดสอบการเชื่อมต่อฐานข้อมูล
        await db_1.default.raw('SELECT 1');
        console.log('Database connected successfully');
        app_1.default.listen(PORT, () => {
            console.log(`GeoCheck Event API running on port ${PORT}`);
            console.log(`http://localhost:${PORT}`);
        });
    }
    catch (error) {
        console.error('Database connection failed:', error);
        process.exit(1);
    }
}
startServer();
