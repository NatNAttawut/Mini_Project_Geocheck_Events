"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.up = up;
exports.down = down;
async function up(knex) {
    await knex.schema.createTable("checkins", (table) => {
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
        // ตำแหน่งของ User ขณะกด Check-in
        table.decimal("latitude", 10, 7).notNullable();
        table.decimal("longitude", 10, 7).notNullable();
        // ระยะห่างจากจุดกิจกรรม หน่วยเป็นเมตร
        table.decimal("distance_meters", 10, 2).notNullable();
        table.timestamp("checked_in_at").defaultTo(knex.fn.now());
        table.timestamp("created_at").defaultTo(knex.fn.now());
        // User Check-in Event เดิมได้ครั้งเดียว
        table.unique(["user_id", "event_id"]);
    });
}
async function down(knex) {
    await knex.schema.dropTableIfExists("checkins");
}
