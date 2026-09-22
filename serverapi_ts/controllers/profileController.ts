import { Request, Response } from "express";
import bcrypt from "bcrypt";
import db from "../utils/db";

// =============================================================
// GET PROFILE
// =============================================================

export const getProfile = async (
  req: Request,
  res: Response
) => {
  try {
    const userId = Number(
      (req as any).user?.id
    );

    if (!userId) {
      return res.status(401).json({
        success: false,
        message: "กรุณาเข้าสู่ระบบ",
      });
    }

    const user = await db("users")
      .select(
        "id",
        "firstname",
        "lastname",
        "student_id",
        "email",
        "role",
        "created_at",
        "updated_at"
      )
      .where("id", userId)
      .first();

    if (!user) {
      return res.status(404).json({
        success: false,
        message: "ไม่พบข้อมูลผู้ใช้",
      });
    }

    // จำนวนกิจกรรมที่ลงทะเบียน
    const registeredResult =
      await db("event_registrations")
        .where({
          user_id: userId,
          status: "registered",
        })
        .count("* as count")
        .first();

    // จำนวนกิจกรรมที่เช็กอินแล้ว
    const checkinResult =
      await db("checkins")
        .where("user_id", userId)
        .count("* as count")
        .first();

    return res.status(200).json({
      success: true,

      user: {
        ...user,

        registered_events: Number(
          registeredResult?.count ?? 0
        ),

        checked_in_events: Number(
          checkinResult?.count ?? 0
        ),
      },
    });
  } catch (error) {
    console.error(
      "GET PROFILE ERROR:",
      error
    );

    return res.status(500).json({
      success: false,
      message:
        "ไม่สามารถโหลดข้อมูลโปรไฟล์ได้",
    });
  }
};

// =============================================================
// UPDATE PROFILE
// =============================================================

export const updateProfile = async (
  req: Request,
  res: Response
) => {
  try {
    const userId = Number(
      (req as any).user?.id
    );

    if (!userId) {
      return res.status(401).json({
        success: false,
        message: "กรุณาเข้าสู่ระบบ",
      });
    }

    const firstname = String(
      req.body.firstname ?? ""
    ).trim();

    const lastname = String(
      req.body.lastname ?? ""
    ).trim();

    const studentId =
      req.body.student_id == null
        ? null
        : String(
            req.body.student_id
          ).trim();

    if (!firstname) {
      return res.status(400).json({
        success: false,
        message: "กรุณากรอกชื่อ",
      });
    }

    if (!lastname) {
      return res.status(400).json({
        success: false,
        message: "กรุณากรอกนามสกุล",
      });
    }

    // =========================================================
    // Student ID ซ้ำหรือไม่
    // =========================================================

    if (
      studentId != null &&
      studentId !== ""
    ) {
      const duplicate =
        await db("users")
          .where(
            "student_id",
            studentId
          )
          .whereNot(
            "id",
            userId
          )
          .first();

      if (duplicate) {
        return res.status(400).json({
          success: false,
          message:
            "รหัสนักศึกษานี้ถูกใช้งานแล้ว",
        });
      }
    }

    await db("users")
      .where("id", userId)
      .update({
        firstname,
        lastname,

        student_id:
          studentId === ""
            ? null
            : studentId,

        updated_at:
          db.fn.now(),
      });

    const updatedUser =
      await db("users")
        .select(
          "id",
          "firstname",
          "lastname",
          "student_id",
          "email",
          "role",
          "created_at",
          "updated_at"
        )
        .where("id", userId)
        .first();

    return res.status(200).json({
      success: true,
      message:
        "แก้ไขข้อมูลโปรไฟล์เรียบร้อยแล้ว",
      user: updatedUser,
    });
  } catch (error) {
    console.error(
      "UPDATE PROFILE ERROR:",
      error
    );

    return res.status(500).json({
      success: false,
      message:
        "ไม่สามารถแก้ไขข้อมูลโปรไฟล์ได้",
    });
  }
};

// =============================================================
// CHANGE PASSWORD
// =============================================================

export const changePassword = async (
  req: Request,
  res: Response
) => {
  try {
    const userId = Number(
      (req as any).user?.id
    );

    if (!userId) {
      return res.status(401).json({
        success: false,
        message: "กรุณาเข้าสู่ระบบ",
      });
    }

    const currentPassword =
      String(
        req.body.current_password ??
          ""
      );

    const newPassword =
      String(
        req.body.new_password ??
          ""
      );

    const confirmPassword =
      String(
        req.body.confirm_password ??
          ""
      );

    if (!currentPassword) {
      return res.status(400).json({
        success: false,
        message:
          "กรุณากรอกรหัสผ่านปัจจุบัน",
      });
    }

    if (newPassword.length < 6) {
      return res.status(400).json({
        success: false,
        message:
          "รหัสผ่านใหม่ต้องมีอย่างน้อย 6 ตัวอักษร",
      });
    }

    if (
      newPassword !==
      confirmPassword
    ) {
      return res.status(400).json({
        success: false,
        message:
          "ยืนยันรหัสผ่านใหม่ไม่ตรงกัน",
      });
    }

    if (
      currentPassword ===
      newPassword
    ) {
      return res.status(400).json({
        success: false,
        message:
          "รหัสผ่านใหม่ต้องไม่เหมือนรหัสผ่านเดิม",
      });
    }

    const user =
      await db("users")
        .where(
          "id",
          userId
        )
        .first();

    if (!user) {
      return res.status(404).json({
        success: false,
        message: "ไม่พบข้อมูลผู้ใช้",
      });
    }

    const passwordCorrect =
      await bcrypt.compare(
        currentPassword,
        user.password
      );

    if (!passwordCorrect) {
      return res.status(400).json({
        success: false,
        message:
          "รหัสผ่านปัจจุบันไม่ถูกต้อง",
      });
    }

    const hashedPassword =
      await bcrypt.hash(
        newPassword,
        10
      );

    await db("users")
      .where("id", userId)
      .update({
        password:
          hashedPassword,

        updated_at:
          db.fn.now(),
      });

    return res.status(200).json({
      success: true,
      message:
        "เปลี่ยนรหัสผ่านเรียบร้อยแล้ว",
    });
  } catch (error) {
    console.error(
      "CHANGE PASSWORD ERROR:",
      error
    );

    return res.status(500).json({
      success: false,
      message:
        "ไม่สามารถเปลี่ยนรหัสผ่านได้",
    });
  }
};