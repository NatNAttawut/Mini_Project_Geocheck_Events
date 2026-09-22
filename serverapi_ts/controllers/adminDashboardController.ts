import { Request, Response } from "express";
import db from "../utils/db";

export const getDashboard = async (
  req: Request,
  res: Response
) => {
  try {
    // =====================================================
    // Summary
    // =====================================================

    const [
      userResult,
      eventResult,
      openEventResult,
      todayCheckinResult,
    ] = await Promise.all([
      // สมาชิกทั่วไปทั้งหมด
      db("users")
        .where("role", "user")
        .count("* as count")
        .first(),

      // กิจกรรมทั้งหมด
      db("events")
        .count("* as count")
        .first(),

      // กิจกรรมที่เปิดรับสมัคร
      db("events")
        .where("status", "open")
        .count("* as count")
        .first(),

      // เช็กอินวันนี้
      db("checkins")
        .whereRaw(
          "DATE(checked_in_at) = CURDATE()"
        )
        .count("* as count")
        .first(),
    ]);

    const totalUsers = Number(
      userResult?.count ?? 0
    );

    const totalEvents = Number(
      eventResult?.count ?? 0
    );

    const openEvents = Number(
      openEventResult?.count ?? 0
    );

    const todayCheckins = Number(
      todayCheckinResult?.count ?? 0
    );

    // =====================================================
    // Recent Events
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
      .orderBy("created_at", "desc")
      .limit(3);

    const recentEvents =
      await Promise.all(
        events.map(async (event) => {
          const [
            registrationResult,
            checkinResult,
          ] = await Promise.all([
            db("event_registrations")
              .where({
                event_id: event.id,
                status: "registered",
              })
              .count("* as count")
              .first(),

            db("checkins")
              .where(
                "event_id",
                event.id
              )
              .count("* as count")
              .first(),
          ]);

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

            registered_count: Number(
              registrationResult?.count ?? 0
            ),

            checkin_count: Number(
              checkinResult?.count ?? 0
            ),
          };
        })
      );

    return res.status(200).json({
      success: true,

      summary: {
        total_users: totalUsers,
        total_events: totalEvents,
        open_events: openEvents,
        today_checkins: todayCheckins,
      },

      recent_events: recentEvents,
    });
  } catch (error) {
    console.error(
      "GET DASHBOARD ERROR:",
      error
    );

    return res.status(500).json({
      success: false,
      message:
        "ไม่สามารถโหลดข้อมูล Dashboard ได้",
    });
  }
};