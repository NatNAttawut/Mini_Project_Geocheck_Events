import { Request, Response } from "express";
import bcrypt from "bcrypt";
import db from "../utils/db";

// =========================================================
// Get All Users
// =========================================================

export const getUsers = async (
  req: Request,
  res: Response
) => {
  try {
    const search =
      (req.query.search as string | undefined)?.trim() ?? "";

    let query = db("users")
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
      .where("role", "user")
      .orderBy("id", "desc");

    if (search !== "") {
      query = query.andWhere((builder) => {
        builder
          .where("firstname", "like", `%${search}%`)
          .orWhere("lastname", "like", `%${search}%`)
          .orWhere("email", "like", `%${search}%`)
          .orWhere("student_id", "like", `%${search}%`);
      });
    }

    const users = await query;

    return res.status(200).json({
      success: true,
      total: users.length,
      users,
    });
  } catch (error) {
    console.error("GET USERS ERROR:", error);

    return res.status(500).json({
      success: false,
      message: "ไม่สามารถโหลดข้อมูลสมาชิกได้",
    });
  }
};

// =========================================================
// Create User
// =========================================================

export const createUser = async (
  req: Request,
  res: Response
) => {
  try {
    const {
      firstname,
      lastname,
      student_id,
      email,
      password,
    } = req.body;

    if (
      !firstname ||
      !lastname ||
      !email ||
      !password
    ) {
      return res.status(400).json({
        success: false,
        message: "กรุณากรอกข้อมูลให้ครบ",
      });
    }

    if (password.length < 6) {
      return res.status(400).json({
        success: false,
        message: "รหัสผ่านต้องมีอย่างน้อย 6 ตัวอักษร",
      });
    }

    // -----------------------------------------------------
    // Check Email
    // -----------------------------------------------------

    const emailExists = await db("users")
      .where("email", email.trim())
      .first();

    if (emailExists) {
      return res.status(409).json({
        success: false,
        message: "อีเมลนี้ถูกใช้งานแล้ว",
      });
    }

    // -----------------------------------------------------
    // Check Student ID
    // -----------------------------------------------------

    if (student_id && student_id.trim() !== "") {
      const studentIdExists = await db("users")
        .where("student_id", student_id.trim())
        .first();

      if (studentIdExists) {
        return res.status(409).json({
          success: false,
          message: "รหัสนักศึกษานี้ถูกใช้งานแล้ว",
        });
      }
    }

    // -----------------------------------------------------
    // Hash Password
    // -----------------------------------------------------

    const hashedPassword = await bcrypt.hash(
      password,
      10
    );

    const [userId] = await db("users").insert({
      firstname: firstname.trim(),
      lastname: lastname.trim(),

      student_id:
        student_id && student_id.trim() !== ""
          ? student_id.trim()
          : null,

      email: email.trim(),
      password: hashedPassword,

      // Admin สร้างสมาชิกได้
      // แต่ไม่สามารถสร้าง Admin จากหน้านี้
      role: "user",
    });

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

    return res.status(201).json({
      success: true,
      message: "เพิ่มสมาชิกเรียบร้อยแล้ว",
      user,
    });
  } catch (error) {
    console.error("CREATE USER ERROR:", error);

    return res.status(500).json({
      success: false,
      message: "ไม่สามารถเพิ่มสมาชิกได้",
    });
  }
};

// =========================================================
// Update User
// =========================================================

export const updateUser = async (
  req: Request,
  res: Response
) => {
  try {
    const id = Number(req.params.id);

    if (Number.isNaN(id)) {
      return res.status(400).json({
        success: false,
        message: "รหัสสมาชิกไม่ถูกต้อง",
      });
    }

    const user = await db("users")
      .where("id", id)
      .first();

    if (!user) {
      return res.status(404).json({
        success: false,
        message: "ไม่พบสมาชิก",
      });
    }

    if (user.role === "admin") {
      return res.status(403).json({
        success: false,
        message: "ไม่สามารถแก้ไข Admin จากส่วนนี้ได้",
      });
    }

    const {
      firstname,
      lastname,
      student_id,
      email,
      password,
    } = req.body;

    if (
      !firstname ||
      !lastname ||
      !email
    ) {
      return res.status(400).json({
        success: false,
        message: "กรุณากรอกข้อมูลให้ครบ",
      });
    }

    // -----------------------------------------------------
    // Duplicate Email
    // -----------------------------------------------------

    const emailExists = await db("users")
      .where("email", email.trim())
      .whereNot("id", id)
      .first();

    if (emailExists) {
      return res.status(409).json({
        success: false,
        message: "อีเมลนี้ถูกใช้งานแล้ว",
      });
    }

    // -----------------------------------------------------
    // Duplicate Student ID
    // -----------------------------------------------------

    if (student_id && student_id.trim() !== "") {
      const studentIdExists = await db("users")
        .where(
          "student_id",
          student_id.trim()
        )
        .whereNot("id", id)
        .first();

      if (studentIdExists) {
        return res.status(409).json({
          success: false,
          message: "รหัสนักศึกษานี้ถูกใช้งานแล้ว",
        });
      }
    }

    const updateData: any = {
      firstname: firstname.trim(),
      lastname: lastname.trim(),

      student_id:
        student_id && student_id.trim() !== ""
          ? student_id.trim()
          : null,

      email: email.trim(),

      updated_at: db.fn.now(),
    };

    // ถ้าไม่กรอกรหัสใหม่
    // จะใช้รหัสเดิม
    if (password && password.trim() !== "") {
      if (password.length < 6) {
        return res.status(400).json({
          success: false,
          message:
            "รหัสผ่านต้องมีอย่างน้อย 6 ตัวอักษร",
        });
      }

      updateData.password =
        await bcrypt.hash(password, 10);
    }

    await db("users")
      .where("id", id)
      .update(updateData);

    const updatedUser = await db("users")
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
      .where("id", id)
      .first();

    return res.status(200).json({
      success: true,
      message: "แก้ไขข้อมูลสมาชิกเรียบร้อยแล้ว",
      user: updatedUser,
    });
  } catch (error) {
    console.error("UPDATE USER ERROR:", error);

    return res.status(500).json({
      success: false,
      message: "ไม่สามารถแก้ไขสมาชิกได้",
    });
  }
};

// =========================================================
// Delete User
// =========================================================

export const deleteUser = async (
  req: Request,
  res: Response
) => {
  try {
    const id = Number(req.params.id);

    if (Number.isNaN(id)) {
      return res.status(400).json({
        success: false,
        message: "รหัสสมาชิกไม่ถูกต้อง",
      });
    }

    const user = await db("users")
      .where("id", id)
      .first();

    if (!user) {
      return res.status(404).json({
        success: false,
        message: "ไม่พบสมาชิก",
      });
    }

    if (user.role === "admin") {
      return res.status(403).json({
        success: false,
        message: "ไม่สามารถลบบัญชี Admin ได้",
      });
    }

    // -----------------------------------------------------
    // ลบข้อมูลที่สัมพันธ์กับ User ก่อน
    // -----------------------------------------------------

    await db.transaction(async (trx) => {
      await trx("checkins")
        .where("user_id", id)
        .del();

      await trx("event_registrations")
        .where("user_id", id)
        .del();

      await trx("users")
        .where("id", id)
        .del();
    });

    return res.status(200).json({
      success: true,
      message: "ลบสมาชิกเรียบร้อยแล้ว",
    });
  } catch (error) {
    console.error("DELETE USER ERROR:", error);

    return res.status(500).json({
      success: false,
      message: "ไม่สามารถลบสมาชิกได้",
    });
  }
};