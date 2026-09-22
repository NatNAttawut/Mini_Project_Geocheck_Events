import { Request, Response } from "express";
import db from "../utils/db";

// =============================================================
// Registration Count Subquery
// =============================================================

const registrationCountSubquery = () => {
  return db("event_registrations")
    .select("event_id")
    .count("* as registered_count")
    .where("status", "registered")
    .groupBy("event_id")
    .as("rc");
};

// =============================================================
// GET USER HOME
// =============================================================

export const getUserHome = async (
  req: Request,
  res: Response
) => {
  try {
    const userId = Number(
      (req as any).user?.id
    );

    if (!userId) {
      return res.status(401).json({
        success: false,
        message: "กรุณาเข้าสู่ระบบ",
      });
    }

    // =========================================================
    // USER
    // =========================================================

    const user = await db("users")
      .select(
        "id",
        "firstname",
        "lastname",
        "student_id",
        "email"
      )
      .where("id", userId)
      .first();

    if (!user) {
      return res.status(404).json({
        success: false,
        message: "ไม่พบข้อมูลผู้ใช้",
      });
    }

    // =========================================================
    // COUNTS
    // =========================================================

    const [
      registeredResult,
      checkinResult,
    ] = await Promise.all([
      db("event_registrations")
        .where({
          user_id: userId,
          status: "registered",
        })
        .count("* as count")
        .first(),

      db("checkins")
        .where(
          "user_id",
          userId
        )
        .count("* as count")
        .first(),
    ]);

    const registeredTotal =
      Number(
        registeredResult?.count ?? 0
      );

    const checkedInTotal =
      Number(
        checkinResult?.count ?? 0
      );

    // =========================================================
    // MY REGISTERED EVENTS
    // =========================================================

    const myEvents =
      await db(
        "event_registrations as er"
      )
        .join(
          "events as e",
          "e.id",
          "er.event_id"
        )

        .leftJoin(
          "checkins as c",
          function () {
            this.on(
              "c.event_id",
              "=",
              "er.event_id"
            ).andOn(
              "c.user_id",
              "=",
              "er.user_id"
            );
          }
        )

        .leftJoin(
          registrationCountSubquery(),
          "rc.event_id",
          "e.id"
        )

        .select(
          "e.id",
          "e.title",
          "e.description",
          "e.location_name",
          "e.latitude",
          "e.longitude",
          "e.checkin_radius",
          "e.start_at",
          "e.end_at",
          "e.checkin_start_at",
          "e.checkin_end_at",
          "e.max_participants",
          "e.status",

          "c.id as checkin_id",
          "c.checked_in_at",
          "c.distance_meters"
        )

        .select(
          db.raw(`
            COALESCE(
              rc.registered_count,
              0
            ) AS registered_count
          `)
        )

        .where(
          "er.user_id",
          userId
        )

        .where(
          "er.status",
          "registered"
        )

        .whereNot(
          "e.status",
          "cancelled"
        )

        .orderBy(
          "e.start_at",
          "asc"
        );

    const now =
      new Date();

    // =========================================================
    // Convert Event
    // =========================================================

    const mappedMyEvents =
      myEvents.map(
        (event) => ({
          id:
            event.id,

          title:
            event.title,

          description:
            event.description,

          location_name:
            event.location_name,

          latitude:
            event.latitude,

          longitude:
            event.longitude,

          checkin_radius:
            event.checkin_radius,

          start_at:
            event.start_at,

          end_at:
            event.end_at,

          checkin_start_at:
            event.checkin_start_at,

          checkin_end_at:
            event.checkin_end_at,

          max_participants:
            event.max_participants,

          status:
            event.status,

          registered_count:
            Number(
              event.registered_count ??
                0
            ),

          is_registered:
            true,

          is_checked_in:
            event.checkin_id != null,

          checked_in_at:
            event.checked_in_at,

          checkin_distance:
            event.distance_meters == null
              ? null
              : Number(
                  event.distance_meters
                ),
        })
      );

    // =========================================================
    // UPCOMING EVENTS
    // ยังไม่จบ และ User ลงทะเบียนแล้ว
    // =========================================================

    const upcomingEvents =
      mappedMyEvents.filter(
        (event) => {
          const end =
            new Date(
              event.end_at
            );

          return (
            end >= now &&
            event.status !==
              "completed"
          );
        }
      );

    // =========================================================
    // NEXT EVENT
    // =========================================================

    const nextEvent =
      upcomingEvents.length > 0
        ? upcomingEvents[0]
        : null;

    // =========================================================
    // READY TO CHECK-IN
    // =========================================================

    const checkinReadyEvents =
      mappedMyEvents.filter(
        (event) => {
          if (
            event.is_checked_in ||
            !event.checkin_start_at ||
            !event.checkin_end_at
          ) {
            return false;
          }

          if (
            event.status !== "open" &&
            event.status !== "closed"
          ) {
            return false;
          }

          const start =
            new Date(
              event.checkin_start_at
            );

          const end =
            new Date(
              event.checkin_end_at
            );

          return (
            now >= start &&
            now <= end
          );
        }
      );

    // =========================================================
    // OPEN EVENTS
    // กิจกรรมที่เปิดอยู่
    // =========================================================

    const openEvents =
      await db("events as e")
        .leftJoin(
          registrationCountSubquery(),
          "rc.event_id",
          "e.id"
        )

        .select(
          "e.id",
          "e.title",
          "e.description",
          "e.location_name",
          "e.latitude",
          "e.longitude",
          "e.checkin_radius",
          "e.start_at",
          "e.end_at",
          "e.checkin_start_at",
          "e.checkin_end_at",
          "e.max_participants",
          "e.status"
        )

        .select(
          db.raw(`
            COALESCE(
              rc.registered_count,
              0
            ) AS registered_count
          `)
        )

        .where(
          "e.status",
          "open"
        )

        .orderBy(
          "e.start_at",
          "asc"
        );

    // ID ที่ User สมัครแล้ว
    const registeredEventIds =
      new Set(
        mappedMyEvents.map(
          (event) => Number(
            event.id
          )
        )
      );

    // เอาเฉพาะกิจกรรมที่ยังไม่สมัคร
    // และกิจกรรมยังไม่จบ
    const availableEvents =
      openEvents
        .filter(
          (event) => {
            const eventEnd =
              new Date(
                event.end_at
              );

            return (
              !registeredEventIds.has(
                Number(event.id)
              ) &&
              eventEnd >= now
            );
          }
        )
        .slice(
          0,
          3
        )
        .map(
          (event) => ({
            ...event,

            registered_count:
              Number(
                event.registered_count ??
                  0
              ),

            is_registered:
              false,

            is_checked_in:
              false,

            checked_in_at:
              null,

            checkin_distance:
              null,
          })
        );

    // =========================================================
    // RESPONSE
    // =========================================================

    return res.status(200).json({
      success: true,

      user: {
        id:
          user.id,

        firstname:
          user.firstname,

        lastname:
          user.lastname,

        student_id:
          user.student_id,

        email:
          user.email,
      },

      summary: {
        registered_total:
          registeredTotal,

        checked_in_total:
          checkedInTotal,

        upcoming_total:
          upcomingEvents.length,

        checkin_ready_total:
          checkinReadyEvents.length,
      },

      next_event:
        nextEvent,

      checkin_ready_events:
        checkinReadyEvents,

      open_events:
        availableEvents,
    });
  } catch (error) {
    console.error(
      "GET USER HOME ERROR:",
      error
    );

    return res.status(500).json({
      success: false,
      message:
        "ไม่สามารถโหลดข้อมูลหน้าหลักได้",
    });
  }
};