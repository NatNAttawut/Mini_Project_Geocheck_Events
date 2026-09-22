"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.login = exports.register = void 0;
const bcrypt_1 = __importDefault(require("bcrypt"));
const jsonwebtoken_1 = __importDefault(require("jsonwebtoken"));
const db_1 = __importDefault(require("../utils/db"));
const JWT_SECRET = process.env.JWT_SECRET || "geocheck_default_secret";
const JWT_EXPIRES_IN = (process.env.JWT_EXPIRES_IN || "1h");
// ============================================================
// Register
// ============================================================
const register = async (req, res) => {
    try {
        const { firstname, lastname, student_id, email, password, } = req.body;
        // --------------------------------------------------------
        // ตรวจข้อมูลที่จำเป็น
        // --------------------------------------------------------
        if (!firstname ||
            !lastname ||
            !student_id ||
            !email ||
            !password) {
            res.status(400).json({
                success: false,
                message: "กรุณากรอกข้อมูลให้ครบถ้วน",
            });
            return;
        }
        if (password.length < 6) {
            res.status(400).json({
                success: false,
                message: "รหัสผ่านต้องมีอย่างน้อย 6 ตัวอักษร",
            });
            return;
        }
        // --------------------------------------------------------
        // ตรวจ Email ซ้ำ
        // --------------------------------------------------------
        const existingEmail = await (0, db_1.default)("users")
            .where({ email })
            .first();
        if (existingEmail) {
            res.status(409).json({
                success: false,
                message: "อีเมลนี้ถูกใช้งานแล้ว",
            });
            return;
        }
        // --------------------------------------------------------
        // ตรวจรหัสนักศึกษาซ้ำ
        // --------------------------------------------------------
        const existingStudent = await (0, db_1.default)("users")
            .where({ student_id })
            .first();
        if (existingStudent) {
            res.status(409).json({
                success: false,
                message: "รหัสนักศึกษานี้ถูกใช้งานแล้ว",
            });
            return;
        }
        // --------------------------------------------------------
        // Hash Password
        // --------------------------------------------------------
        const hashedPassword = await bcrypt_1.default.hash(password, 10);
        // --------------------------------------------------------
        // เพิ่ม User
        // role บังคับเป็น user เท่านั้น
        // --------------------------------------------------------
        const [userId] = await (0, db_1.default)("users").insert({
            firstname,
            lastname,
            student_id,
            email,
            password: hashedPassword,
            role: "user",
        });
        const newUser = await (0, db_1.default)("users")
            .select("id", "firstname", "lastname", "student_id", "email", "role", "created_at")
            .where({ id: userId })
            .first();
        res.status(201).json({
            success: true,
            message: "สมัครสมาชิกสำเร็จ",
            user: newUser,
        });
    }
    catch (error) {
        console.error("Register Error:", error);
        res.status(500).json({
            success: false,
            message: "เกิดข้อผิดพลาดจาก Server",
        });
    }
};
exports.register = register;
// ============================================================
// Login
// ============================================================
const login = async (req, res) => {
    try {
        const { email, password } = req.body;
        // --------------------------------------------------------
        // ตรวจข้อมูล
        // --------------------------------------------------------
        if (!email || !password) {
            res.status(400).json({
                success: false,
                message: "กรุณากรอกอีเมลและรหัสผ่าน",
            });
            return;
        }
        // --------------------------------------------------------
        // หา User
        // --------------------------------------------------------
        const user = await (0, db_1.default)("users")
            .where({ email })
            .first();
        if (!user) {
            res.status(401).json({
                success: false,
                message: "อีเมลหรือรหัสผ่านไม่ถูกต้อง",
            });
            return;
        }
        // --------------------------------------------------------
        // เปรียบเทียบ Password กับ bcrypt
        // --------------------------------------------------------
        const passwordMatch = await bcrypt_1.default.compare(password, user.password);
        if (!passwordMatch) {
            res.status(401).json({
                success: false,
                message: "อีเมลหรือรหัสผ่านไม่ถูกต้อง",
            });
            return;
        }
        // --------------------------------------------------------
        // สร้าง JWT
        // --------------------------------------------------------
        const token = jsonwebtoken_1.default.sign({
            id: user.id,
            email: user.email,
            role: user.role,
        }, JWT_SECRET, {
            expiresIn: JWT_EXPIRES_IN,
        });
        // --------------------------------------------------------
        // Response
        // --------------------------------------------------------
        res.status(200).json({
            success: true,
            message: "เข้าสู่ระบบสำเร็จ",
            token,
            user: {
                id: user.id,
                firstname: user.firstname,
                lastname: user.lastname,
                student_id: user.student_id,
                email: user.email,
                role: user.role,
            },
        });
    }
    catch (error) {
        console.error("Login Error:", error);
        res.status(500).json({
            success: false,
            message: "เกิดข้อผิดพลาดจาก Server",
        });
    }
};
exports.login = login;
