import { Knex } from "knex";

export async function up(
  knex: Knex
): Promise<void> {
  await knex.raw(`
    ALTER TABLE users
    MODIFY COLUMN role
    ENUM('user', 'admin', 'super_admin')
    NOT NULL
    DEFAULT 'user'
  `);

  // บัญชีหลักของระบบ
  await knex("users")
    .where(
      "email",
      "admin@geocheck.local"
    )
    .update({
      role: "super_admin",
    });
}

export async function down(
  knex: Knex
): Promise<void> {
  await knex("users")
    .where(
      "role",
      "super_admin"
    )
    .update({
      role: "admin",
    });

  await knex.raw(`
    ALTER TABLE users
    MODIFY COLUMN role
    ENUM('user', 'admin')
    NOT NULL
    DEFAULT 'user'
  `);
}