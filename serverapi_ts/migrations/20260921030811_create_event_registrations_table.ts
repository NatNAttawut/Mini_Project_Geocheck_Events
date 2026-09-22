import type { Knex } from "knex";

export async function up(knex: Knex): Promise<void> {
  await knex.schema.createTable("event_registrations", (table) => {
    table.increments("id").primary();

    table
      .integer("user_id")
      .unsigned()
      .notNullable()
      .references("id")
      .inTable("users")
      .onUpdate("CASCADE")
      .onDelete("CASCADE");

    table
      .integer("event_id")
      .unsigned()
      .notNullable()
      .references("id")
      .inTable("events")
      .onUpdate("CASCADE")
      .onDelete("CASCADE");

    table
      .enu("status", ["registered", "cancelled"])
      .notNullable()
      .defaultTo("registered");

    table.timestamp("registered_at").defaultTo(knex.fn.now());

    table.timestamp("created_at").defaultTo(knex.fn.now());
    table.timestamp("updated_at").defaultTo(knex.fn.now());

    // ป้องกัน User ลงทะเบียน Event เดิมซ้ำ
    table.unique(["user_id", "event_id"]);
  });
}

export async function down(knex: Knex): Promise<void> {
  await knex.schema.dropTableIfExists("event_registrations");
}