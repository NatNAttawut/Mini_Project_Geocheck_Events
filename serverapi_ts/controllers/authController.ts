import { Request, Response } from "express";
import bcrypt from "bcrypt";
import jwt, { Secret, SignOptions } from "jsonwebtoken";
import db from "../utils/db";

const JWT_SECRET: Secret =
  process.env.JWT_SECRET || "geocheck_default_secret";

const JWT_EXPIRES_IN = (
  process.env.JWT_EXPIRES_IN || "1h"
) as SignOptions["expiresIn"];

// ============================================================
// Register
// ============================================================

export const register = async (
  req: Request,
  res: Response
): Promise<void> => {
  try {
    const {
      firstname,
      lastname,
      student_id,
      email,
      password,
    } = req.body;

    // --------------------------------------------------------
    // ตรวจข้อมูลที่จำเป็น
    // --------------------------------------------------------

    if (
      !firstname ||
      !lastname ||
      !student_id ||
      !email ||
      !password
    ) {
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

    const existingEmail = await db("users")
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

    const existingStudent = await db("users")
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

    const hashedPassword = await bcrypt.hash(
      password,
      10
    );

    // --------------------------------------------------------
    // เพิ่ม User
    // role บังคับเป็น user เท่านั้น
    // --------------------------------------------------------

    const [userId] = await db("users").insert({
      firstname,
      lastname,
      student_id,
      email,
      password: hashedPassword,
      role: "user",
    });

    const newUser = await db("users")
      .select(
        "id",
        "firstname",
        "lastname",
        "student_id",
        "email",
        "role",
        "created_at"
      )
      .where({ id: userId })
      .first();

    res.status(201).json({
      success: true,
      message: "สมัครสมาชิกสำเร็จ",
      user: newUser,
    });
  } catch (error) {
    console.error("Register Error:", error);

    res.status(500).json({
      success: false,
      message: "เกิดข้อผิดพลาดจาก Server",
    });
  }
};

// ============================================================
// Login
// ============================================================

export const login = async (
  req: Request,
  res: Response
): Promise<void> => {
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

    const user = await db("users")
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

    const passwordMatch = await bcrypt.compare(
      password,
      user.password
    );

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

    const token = jwt.sign(
      {
        id: user.id,
        email: user.email,
        role: user.role,
      },
      JWT_SECRET,
      {
        expiresIn: JWT_EXPIRES_IN,
      }
    );

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
  } catch (error) {
    console.error("Login Error:", error);

    res.status(500).json({
      success: false,
      message: "เกิดข้อผิดพลาดจาก Server",
    });
  }
};