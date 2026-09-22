import { Request, Response } from "express";

import db from "../utils/db";
import { AuthRequest } from "../middleware/authMiddleware";

// =========================================================
// GET ALL EVENTS
// =========================================================

export const getEvents = async (
  req: Request,
  res: Response
) => {
  try {
    const search =
      (req.query.search as string | undefined)?.trim() ?? "";

    const status =
      (req.query.status as string | undefined)?.trim() ?? "";

    let query = db("events")
      .select(
        "events.id",
        "events.title",
        "events.description",
        "events.location_name",
        "events.latitude",
        "events.longitude",
        "events.checkin_radius",
        "events.start_at",
        "events.end_at",
        "events.checkin_start_at",
        "events.checkin_end_at",
        "events.max_participants",
        "events.status",
        "events.created_by",
        "events.created_at",
        "events.updated_at"
      )
      .orderBy("events.start_at", "desc");

    // Search
    if (search !== "") {
      query = query.where((builder) => {
        builder
          .where(
            "events.title",
            "like",
            `%${search}%`
          )
          .orWhere(
            "events.description",
            "like",
            `%${search}%`
          )
          .orWhere(
            "events.location_name",
            "like",
            `%${search}%`
          );
      });
    }

    // Filter Status
    if (status !== "" && status !== "all") {
      query = query.andWhere(
        "events.status",
        status
      );
    }

    const events = await query;

    // =====================================================
    // เพิ่มจำนวนผู้ลงทะเบียน + เช็กอิน
    // =====================================================

    const result = await Promise.all(
      events.map(async (event) => {
        const registrationResult =
          await db("event_registrations")
            .where({
              event_id: event.id,
              status: "registered",
            })
            .count<{ count: number | string }[]>(
              "* as count"
            );

        const checkinResult =
          await db("checkins")
            .where({
              event_id: event.id,
            })
            .count<{ count: number | string }[]>(
              "* as count"
            );

        return {
          ...event,

          registered_count: Number(
            registrationResult[0]?.count ?? 0
          ),

          checkin_count: Number(
            checkinResult[0]?.count ?? 0
          ),
        };
      })
    );

    return res.status(200).json({
      success: true,
      total: result.length,
      events: result,
    });
  } catch (error) {
    console.error(
      "GET EVENTS ERROR:",
      error
    );

    return res.status(500).json({
      success: false,
      message:
        "ไม่สามารถโหลดข้อมูลกิจกรรมได้",
    });
  }
};

// =========================================================
// CREATE EVENT
// =========================================================

export const createEvent = async (
  req: AuthRequest,
  res: Response
) => {
  try {
    const {
      title,
      description,
      location_name,
      latitude,
      longitude,
      checkin_radius,
      start_at,
      end_at,
      checkin_start_at,
      checkin_end_at,
      max_participants,
      status,
    } = req.body;

    // =====================================================
    // Required
    // =====================================================

    if (
      !title ||
      !location_name ||
      latitude === undefined ||
      longitude === undefined ||
      !start_at ||
      !end_at
    ) {
      return res.status(400).json({
        success: false,
        message:
          "กรุณากรอกข้อมูลกิจกรรมให้ครบ",
      });
    }

    // =====================================================
    // Validate Number
    // =====================================================

    const lat = Number(latitude);
    const lng = Number(longitude);

    if (
      Number.isNaN(lat) ||
      lat < -90 ||
      lat > 90
    ) {
      return res.status(400).json({
        success: false,
        message: "Latitude ไม่ถูกต้อง",
      });
    }

    if (
      Number.isNaN(lng) ||
      lng < -180 ||
      lng > 180
    ) {
      return res.status(400).json({
        success: false,
        message: "Longitude ไม่ถูกต้อง",
      });
    }

    const radius =
      Number(checkin_radius ?? 100);

    if (
      Number.isNaN(radius) ||
      radius <= 0
    ) {
      return res.status(400).json({
        success: false,
        message:
          "รัศมีเช็กอินต้องมากกว่า 0 เมตร",
      });
    }

    // =====================================================
    // Validate Date
    // =====================================================

    const startDate =
      new Date(start_at);

    const endDate =
      new Date(end_at);

    if (
      Number.isNaN(startDate.getTime()) ||
      Number.isNaN(endDate.getTime())
    ) {
      return res.status(400).json({
        success: false,
        message:
          "วันเวลาของกิจกรรมไม่ถูกต้อง",
      });
    }

    if (endDate <= startDate) {
      return res.status(400).json({
        success: false,
        message:
          "เวลาสิ้นสุดต้องอยู่หลังเวลาเริ่มกิจกรรม",
      });
    }

    // =====================================================
    // Check-in Time
    // =====================================================

    if (
      checkin_start_at &&
      checkin_end_at
    ) {
      const checkinStart =
        new Date(checkin_start_at);

      const checkinEnd =
        new Date(checkin_end_at);

      if (checkinEnd <= checkinStart) {
        return res.status(400).json({
          success: false,
          message:
            "เวลาปิดเช็กอินต้องอยู่หลังเวลาเปิดเช็กอิน",
        });
      }
    }

    const validStatuses = [
      "draft",
      "open",
      "closed",
      "completed",
      "cancelled",
    ];

    const eventStatus =
      validStatuses.includes(status)
        ? status
        : "draft";

    // =====================================================
    // Insert
    // =====================================================

    const [eventId] =
      await db("events").insert({
        title: title.trim(),

        description:
          description?.trim() || null,

        location_name:
          location_name.trim(),

        latitude: lat,

        longitude: lng,

        checkin_radius: radius,

        start_at,

        end_at,

        checkin_start_at:
          checkin_start_at || null,

        checkin_end_at:
          checkin_end_at || null,

        max_participants:
          max_participants
            ? Number(max_participants)
            : null,

        status: eventStatus,

        created_by: req.user!.id,
      });

    const event =
      await db("events")
        .where("id", eventId)
        .first();

    return res.status(201).json({
      success: true,
      message:
        "สร้างกิจกรรมเรียบร้อยแล้ว",
      event,
    });
  } catch (error) {
    console.error(
      "CREATE EVENT ERROR:",
      error
    );

    return res.status(500).json({
      success: false,
      message:
        "ไม่สามารถสร้างกิจกรรมได้",
    });
  }
};

// =========================================================
// UPDATE EVENT
// =========================================================

export const updateEvent = async (
  req: Request,
  res: Response
) => {
  try {
    const id =
      Number(req.params.id);

    if (Number.isNaN(id)) {
      return res.status(400).json({
        success: false,
        message:
          "รหัสกิจกรรมไม่ถูกต้อง",
      });
    }

    const existing =
      await db("events")
        .where("id", id)
        .first();

    if (!existing) {
      return res.status(404).json({
        success: false,
        message: "ไม่พบกิจกรรม",
      });
    }

    const {
      title,
      description,
      location_name,
      latitude,
      longitude,
      checkin_radius,
      start_at,
      end_at,
      checkin_start_at,
      checkin_end_at,
      max_participants,
      status,
    } = req.body;

    if (
      !title ||
      !location_name ||
      latitude === undefined ||
      longitude === undefined ||
      !start_at ||
      !end_at
    ) {
      return res.status(400).json({
        success: false,
        message:
          "กรุณากรอกข้อมูลกิจกรรมให้ครบ",
      });
    }

    const lat =
      Number(latitude);

    const lng =
      Number(longitude);

    if (
      Number.isNaN(lat) ||
      lat < -90 ||
      lat > 90
    ) {
      return res.status(400).json({
        success: false,
        message:
          "Latitude ไม่ถูกต้อง",
      });
    }

    if (
      Number.isNaN(lng) ||
      lng < -180 ||
      lng > 180
    ) {
      return res.status(400).json({
        success: false,
        message:
          "Longitude ไม่ถูกต้อง",
      });
    }

    const startDate =
      new Date(start_at);

    const endDate =
      new Date(end_at);

    if (endDate <= startDate) {
      return res.status(400).json({
        success: false,
        message:
          "เวลาสิ้นสุดต้องอยู่หลังเวลาเริ่มกิจกรรม",
      });
    }

    if (
      checkin_start_at &&
      checkin_end_at
    ) {
      const checkinStart =
        new Date(checkin_start_at);

      const checkinEnd =
        new Date(checkin_end_at);

      if (
        checkinEnd <= checkinStart
      ) {
        return res.status(400).json({
          success: false,
          message:
            "เวลาปิดเช็กอินต้องอยู่หลังเวลาเปิดเช็กอิน",
        });
      }
    }

    const validStatuses = [
      "draft",
      "open",
      "closed",
      "completed",
      "cancelled",
    ];

    if (
      !validStatuses.includes(status)
    ) {
      return res.status(400).json({
        success: false,
        message:
          "สถานะกิจกรรมไม่ถูกต้อง",
      });
    }

    await db("events")
      .where("id", id)
      .update({
        title: title.trim(),

        description:
          description?.trim() || null,

        location_name:
          location_name.trim(),

        latitude: lat,

        longitude: lng,

        checkin_radius:
          Number(checkin_radius ?? 100),

        start_at,

        end_at,

        checkin_start_at:
          checkin_start_at || null,

        checkin_end_at:
          checkin_end_at || null,

        max_participants:
          max_participants
            ? Number(max_participants)
            : null,

        status,

        updated_at: db.fn.now(),
      });

    const updatedEvent =
      await db("events")
        .where("id", id)
        .first();

    return res.status(200).json({
      success: true,
      message:
        "แก้ไขกิจกรรมเรียบร้อยแล้ว",
      event: updatedEvent,
    });
  } catch (error) {
    console.error(
      "UPDATE EVENT ERROR:",
      error
    );

    return res.status(500).json({
      success: false,
      message:
        "ไม่สามารถแก้ไขกิจกรรมได้",
    });
  }
};

// =========================================================
// DELETE EVENT
// =========================================================

export const deleteEvent = async (
  req: Request,
  res: Response
) => {
  try {
    const id =
      Number(req.params.id);

    const event =
      await db("events")
        .where("id", id)
        .first();

    if (!event) {
      return res.status(404).json({
        success: false,
        message: "ไม่พบกิจกรรม",
      });
    }

    await db.transaction(
      async (trx) => {
        await trx("checkins")
          .where(
            "event_id",
            id
          )
          .del();

        await trx(
          "event_registrations"
        )
          .where(
            "event_id",
            id
          )
          .del();

        await trx("events")
          .where(
            "id",
            id
          )
          .del();
      }
    );

    return res.status(200).json({
      success: true,
      message:
        "ลบกิจกรรมเรียบร้อยแล้ว",
    });
  } catch (error) {
    console.error(
      "DELETE EVENT ERROR:",
      error
    );

    return res.status(500).json({
      success: false,
      message:
        "ไม่สามารถลบกิจกรรมได้",
    });
  }
};

// =========================================================
// GET EVENT DETAIL
// =========================================================

export const getEventDetail = async (
  req: Request,
  res: Response
) => {
  try {
    const id = Number(req.params.id);

    if (Number.isNaN(id)) {
      return res.status(400).json({
        success: false,
        message: "รหัสกิจกรรมไม่ถูกต้อง",
      });
    }

    // =====================================================
    // Event
    // =====================================================

    const event = await db("events")
      .select(
        "id",
        "title",
        "description",
        "location_name",
        "latitude",
        "longitude",
        "checkin_radius",
        "start_at",
        "end_at",
        "checkin_start_at",
        "checkin_end_at",
        "max_participants",
        "status",
        "created_by",
        "created_at",
        "updated_at"
      )
      .where("id", id)
      .first();

    if (!event) {
      return res.status(404).json({
        success: false,
        message: "ไม่พบกิจกรรม",
      });
    }

    // =====================================================
    // Registered Users + Check-in
    // =====================================================

    const participants =
      await db("event_registrations as er")
        .join(
          "users as u",
          "u.id",
          "er.user_id"
        )
        .leftJoin(
          "checkins as c",
          function () {
            this.on(
              "c.user_id",
              "=",
              "er.user_id"
            ).andOn(
              "c.event_id",
              "=",
              "er.event_id"
            );
          }
        )
        .select(
          "er.id as registration_id",
          "er.user_id",
          "er.registered_at",
          "er.status as registration_status",

          "u.firstname",
          "u.lastname",
          "u.student_id",
          "u.email",

          "c.id as checkin_id",
          "c.checked_in_at",
          "c.distance_meters",
          "c.latitude as checkin_latitude",
          "c.longitude as checkin_longitude"
        )
        .where(
          "er.event_id",
          id
        )
        .where(
          "er.status",
          "registered"
        )
        .orderBy(
          "u.firstname",
          "asc"
        )
        .orderBy(
          "u.lastname",
          "asc"
        );

    // =====================================================
    // Summary
    // =====================================================

    const registeredCount =
      participants.length;

    const checkinCount =
      participants.filter(
        (participant) =>
          participant.checkin_id != null
      ).length;

    const pendingCount =
      registeredCount -
      checkinCount;

    return res.status(200).json({
      success: true,

      event: {
        ...event,

        registered_count:
          registeredCount,

        checkin_count:
          checkinCount,

        pending_count:
          pendingCount,
      },

      participants:
        participants.map(
          (participant) => ({
            ...participant,

            checked_in:
              participant.checkin_id !=
              null,
          })
        ),
    });
  } catch (error) {
    console.error(
      "GET EVENT DETAIL ERROR:",
      error
    );

    return res.status(500).json({
      success: false,
      message:
        "ไม่สามารถโหลดรายละเอียดกิจกรรมได้",
    });
  }
};