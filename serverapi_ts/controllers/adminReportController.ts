import { Request, Response } from "express";
import db from "../utils/db";

// =========================================================
// Admin Report Summary
// =========================================================

export const getReportSummary = async (
  req: Request,
  res: Response
) => {
  try {
    // =====================================================
    // สมาชิกทั้งหมด
    // นับเฉพาะ role = user
    // =====================================================

    const userResult = await db("users")
      .where("role", "user")
      .count("* as count")
      .first();

    const totalUsers = Number(
      userResult?.count ?? 0
    );

    // =====================================================
    // กิจกรรมทั้งหมด
    // =====================================================

    const eventResult = await db("events")
      .count("* as count")
      .first();

    const totalEvents = Number(
      eventResult?.count ?? 0
    );

    // =====================================================
    // กิจกรรมที่เปิดรับสมัคร
    // =====================================================

    const openEventResult = await db("events")
      .where("status", "open")
      .count("* as count")
      .first();

    const openEvents = Number(
      openEventResult?.count ?? 0
    );

    // =====================================================
    // การลงทะเบียนทั้งหมด
    // =====================================================

    const registrationResult =
      await db("event_registrations")
        .where("status", "registered")
        .count("* as count")
        .first();

    const totalRegistrations = Number(
      registrationResult?.count ?? 0
    );

    // =====================================================
    // Check-in ทั้งหมด
    // =====================================================

    const checkinResult =
      await db("checkins")
        .count("* as count")
        .first();

    const totalCheckins = Number(
      checkinResult?.count ?? 0
    );

    // =====================================================
    // อัตราการเข้าร่วม
    // =====================================================

    const attendanceRate =
      totalRegistrations > 0
        ? Number(
            (
              (totalCheckins /
                totalRegistrations) *
              100
            ).toFixed(2)
          )
        : 0;

    // =====================================================
    // รายงานแต่ละกิจกรรม
    // =====================================================

    const events = await db("events")
      .select(
        "id",
        "title",
        "location_name",
        "start_at",
        "end_at",
        "status",
        "max_participants"
      )
      .orderBy(
        "start_at",
        "desc"
      );

    const eventReports =
      await Promise.all(
        events.map(async (event) => {
          const registrations =
            await db(
              "event_registrations"
            )
              .where({
                event_id: event.id,
                status: "registered",
              })
              .count("* as count")
              .first();

          const checkins =
            await db("checkins")
              .where(
                "event_id",
                event.id
              )
              .count("* as count")
              .first();

          const registeredCount =
            Number(
              registrations?.count ?? 0
            );

          const checkinCount =
            Number(
              checkins?.count ?? 0
            );

          const rate =
            registeredCount > 0
              ? Number(
                  (
                    (checkinCount /
                      registeredCount) *
                    100
                  ).toFixed(2)
                )
              : 0;

          return {
            id: event.id,
            title: event.title,
            location_name:
              event.location_name,

            start_at:
              event.start_at,

            end_at:
              event.end_at,

            status:
              event.status,

            max_participants:
              event.max_participants,

            registered_count:
              registeredCount,

            checkin_count:
              checkinCount,

            attendance_rate:
              rate,
          };
        })
      );

    // =====================================================
    // Response
    // =====================================================

    return res.status(200).json({
      success: true,

      summary: {
        total_users:
          totalUsers,

        total_events:
          totalEvents,

        open_events:
          openEvents,

        total_registrations:
          totalRegistrations,

        total_checkins:
          totalCheckins,

        attendance_rate:
          attendanceRate,
      },

      events:
        eventReports,
    });
  } catch (error) {
    console.error(
      "GET REPORT ERROR:",
      error
    );

    return res.status(500).json({
      success: false,
      message:
        "ไม่สามารถโหลดข้อมูลรายงานได้",
    });
  }
};