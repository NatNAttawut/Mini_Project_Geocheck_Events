import {
  Request,
  Response,
} from "express";

import bcrypt from "bcrypt";

import db from "../utils/db";

// =============================================================
// GET ACCOUNTS
// =============================================================

export const getAccessAccounts =
  async (
    req: Request,
    res: Response
  ) => {
    try {
      const accounts =
        await db("users")
          .select(
            "id",
            "firstname",
            "lastname",
            "student_id",
            "email",
            "role",
            "created_at"
          )
          .whereIn(
            "role",
            [
              "user",
              "admin",
              "super_admin",
            ]
          )
          .orderByRaw(`
            CASE role
              WHEN 'super_admin' THEN 1
              WHEN 'admin' THEN 2
              ELSE 3
            END
          `)
          .orderBy(
            "firstname",
            "asc"
          );

      return res.status(200).json({
        success: true,
        accounts,
      });
    } catch (error) {
      console.error(
        "GET ACCESS ACCOUNTS ERROR:",
        error
      );

      return res.status(500).json({
        success: false,
        message:
          "ไม่สามารถโหลดข้อมูลสิทธิ์ได้",
      });
    }
  };

// =============================================================
// CREATE ADMIN
// =============================================================

export const createAdmin =
  async (
    req: Request,
    res: Response
  ) => {
    try {
      const firstname =
        String(
          req.body.firstname ?? ""
        ).trim();

      const lastname =
        String(
          req.body.lastname ?? ""
        ).trim();

      const email =
        String(
          req.body.email ?? ""
        )
          .trim()
          .toLowerCase();

      const password =
        String(
          req.body.password ?? ""
        );

      if (
        !firstname ||
        !lastname ||
        !email ||
        !password
      ) {
        return res.status(400).json({
          success: false,
          message:
            "กรุณากรอกข้อมูลให้ครบ",
        });
      }

      if (password.length < 6) {
        return res.status(400).json({
          success: false,
          message:
            "รหัสผ่านต้องมีอย่างน้อย 6 ตัวอักษร",
        });
      }

      const exists =
        await db("users")
          .where("email", email)
          .first();

      if (exists) {
        return res.status(400).json({
          success: false,
          message:
            "อีเมลนี้มีบัญชีอยู่แล้ว",
        });
      }

      const hashedPassword =
        await bcrypt.hash(
          password,
          10
        );

      const ids =
        await db("users").insert({
          firstname,
          lastname,

          student_id: null,

          email,

          password:
            hashedPassword,

          // Super Admin สร้างได้แค่ Admin
          // ไม่สามารถสร้าง Super Admin เพิ่มผ่าน API นี้
          role: "admin",

          created_at:
            db.fn.now(),

          updated_at:
            db.fn.now(),
        });

      const id = Number(
        ids[0]
      );

      return res.status(201).json({
        success: true,
        message:
          "เพิ่มผู้ดูแลระบบเรียบร้อยแล้ว",

        user: {
          id,
          firstname,
          lastname,
          email,
          role:
            "admin",
        },
      });
    } catch (error) {
      console.error(
        "CREATE ADMIN ERROR:",
        error
      );

      return res.status(500).json({
        success: false,
        message:
          "ไม่สามารถเพิ่มผู้ดูแลระบบได้",
      });
    }
  };

// =============================================================
// CHANGE ROLE
// user <-> admin
// =============================================================

export const changeUserRole =
  async (
    req: Request,
    res: Response
  ) => {
    try {
      const currentUserId =
        Number(
          (req as any).user?.id
        );

      const targetId =
        Number(
          req.params.id
        );

      const role =
        String(
          req.body.role ?? ""
        );

      if (
        !Number.isInteger(targetId) ||
        targetId <= 0
      ) {
        return res.status(400).json({
          success: false,
          message:
            "รหัสผู้ใช้ไม่ถูกต้อง",
        });
      }

      if (
        role !== "user" &&
        role !== "admin"
      ) {
        return res.status(400).json({
          success: false,
          message:
            "สิทธิ์ที่ระบุไม่ถูกต้อง",
        });
      }

      if (
        currentUserId === targetId
      ) {
        return res.status(400).json({
          success: false,
          message:
            "ไม่สามารถเปลี่ยนสิทธิ์บัญชีของตนเองได้",
        });
      }

      const target =
        await db("users")
          .where(
            "id",
            targetId
          )
          .first();

      if (!target) {
        return res.status(404).json({
          success: false,
          message:
            "ไม่พบบัญชีผู้ใช้",
        });
      }

      // ห้ามแตะ Super Admin
      if (
        target.role ===
        "super_admin"
      ) {
        return res.status(403).json({
          success: false,
          message:
            "ไม่สามารถเปลี่ยนสิทธิ์ Super Admin ได้",
        });
      }

      if (
        target.role === role
      ) {
        return res.status(400).json({
          success: false,
          message:
            "บัญชีนี้มีสิทธิ์ดังกล่าวอยู่แล้ว",
        });
      }

      await db("users")
        .where(
          "id",
          targetId
        )
        .update({
          role,

          updated_at:
            db.fn.now(),
        });

      return res.status(200).json({
        success: true,

        message:
          role === "admin"
            ? "แต่งตั้งเป็นผู้ดูแลระบบเรียบร้อยแล้ว"
            : "ถอนสิทธิ์ผู้ดูแลระบบเรียบร้อยแล้ว",
      });
    } catch (error) {
      console.error(
        "CHANGE USER ROLE ERROR:",
        error
      );

      return res.status(500).json({
        success: false,
        message:
          "ไม่สามารถเปลี่ยนสิทธิ์ได้",
      });
    }
  };