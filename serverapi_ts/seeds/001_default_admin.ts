import type { Knex } from "knex";
import bcrypt from "bcrypt";
import dotenv from "dotenv";

dotenv.config();

export async function seed(knex: Knex): Promise<void> {
  const email = process.env.DEFAULT_ADMIN_EMAIL;
  const password = process.env.DEFAULT_ADMIN_PASSWORD;

  if (!email || !password) {
    throw new Error(
      "DEFAULT_ADMIN_EMAIL หรือ DEFAULT_ADMIN_PASSWORD ไม่ได้กำหนดใน .env"
    );
  }

  // ตรวจว่ามี Admin ตัวนี้อยู่แล้วหรือไม่
  const existingAdmin = await knex("users")
    .where({ email })
    .first();

  if (existingAdmin) {
    console.log("Default admin already exists");
    return;
  }

  // เข้ารหัส Password ก่อนเก็บลง Database
  const hashedPassword = await bcrypt.hash(password, 10);

  await knex("users").insert({
    firstname:
      process.env.DEFAULT_ADMIN_FIRSTNAME || "GeoCheck",

    lastname:
      process.env.DEFAULT_ADMIN_LASTNAME || "Administrator",

    student_id: null,

    email,

    password: hashedPassword,

    role: "admin",
  });

  console.log("Default admin created successfully");
}