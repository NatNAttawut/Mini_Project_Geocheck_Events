import type { Knex } from "knex";

export async function up(knex: Knex): Promise<void> {
  await knex.schema.createTable("users", (table) => {
    table.increments("id").primary();

    table.string("firstname", 100).notNullable();
    table.string("lastname", 100).notNullable();

    table.string("student_id", 30).nullable().unique();

    table.string("email", 255).notNullable().unique();
    table.string("password", 255).notNullable();

    table
      .enu("role", ["user", "admin"])
      .notNullable()
      .defaultTo("user");

    table.timestamp("created_at").defaultTo(knex.fn.now());
    table.timestamp("updated_at").defaultTo(knex.fn.now());
  });
}

export async function down(knex: Knex): Promise<void> {
  await knex.schema.dropTableIfExists("users");
}