"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.up = up;
exports.down = down;
async function up(knex) {
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
async function down(knex) {
    await knex.schema.dropTableIfExists("users");
}
