"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.up = up;
exports.down = down;
async function up(knex) {
    await knex.schema.createTable("events", (table) => {
        table.increments("id").primary();
        table.string("title", 255).notNullable();
        table.text("description").nullable();
        // ชื่อสถานที่จัดกิจกรรม
        table.string("location_name", 255).notNullable();
        // พิกัดของกิจกรรม
        table.decimal("latitude", 10, 7).notNullable();
        table.decimal("longitude", 10, 7).notNullable();
        // ระยะที่อนุญาตให้ Check-in หน่วยเป็นเมตร
        table.integer("checkin_radius").unsigned().notNullable().defaultTo(100);
        // วันเวลาเริ่มและสิ้นสุดกิจกรรม
        table.dateTime("start_at").notNullable();
        table.dateTime("end_at").notNullable();
        // ช่วงเวลาที่อนุญาตให้ Check-in
        table.dateTime("checkin_start_at").nullable();
        table.dateTime("checkin_end_at").nullable();
        // จำนวนผู้เข้าร่วมสูงสุด
        // null = ไม่จำกัด
        table.integer("max_participants").unsigned().nullable();
        table
            .enu("status", [
            "draft",
            "open",
            "closed",
            "completed",
            "cancelled",
        ])
            .notNullable()
            .defaultTo("draft");
        // ผู้สร้างกิจกรรม
        table
            .integer("created_by")
            .unsigned()
            .notNullable()
            .references("id")
            .inTable("users")
            .onUpdate("CASCADE")
            .onDelete("RESTRICT");
        table.timestamp("created_at").defaultTo(knex.fn.now());
        table.timestamp("updated_at").defaultTo(knex.fn.now());
    });
}
async function down(knex) {
    await knex.schema.dropTableIfExists("events");
}
