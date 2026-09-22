import { Request, Response } from "express";
import db from "../utils/db";

// =============================================================
// CALCULATE DISTANCE - HAVERSINE
// =============================================================

const calculateDistanceMeters = (
  lat1: number,
  lng1: number,
  lat2: number,
  lng2: number
) => {
  const earthRadius = 6371000;

  const toRadians = (
    degree: number
  ) => {
    return (
      degree *
      Math.PI
    ) / 180;
  };

  const dLat =
    toRadians(
      lat2 - lat1
    );

  const dLng =
    toRadians(
      lng2 - lng1
    );

  const a =
    Math.sin(
      dLat / 2
    ) *
      Math.sin(
        dLat / 2
      ) +
    Math.cos(
      toRadians(
        lat1
      )
    ) *
      Math.cos(
        toRadians(
          lat2
        )
      ) *
      Math.sin(
        dLng / 2
      ) *
      Math.sin(
        dLng / 2
      );

  const c =
    2 *
    Math.atan2(
      Math.sqrt(a),
      Math.sqrt(
        1 - a
      )
    );

  return earthRadius * c;
};

// =============================================================
// GET EVENTS FOR USER
// =============================================================

export const getUserEvents = async (
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

    const search = String(
      req.query.search ?? ""
    ).trim();

    const status = String(
      req.query.status ?? "all"
    ).trim();

    // =========================================================
    // จำนวนคนลงทะเบียนต่อกิจกรรม
    // =========================================================

    const registrationCountQuery =
      db("event_registrations")
        .select("event_id")
        .count("* as registered_count")
        .where(
          "status",
          "registered"
        )
        .groupBy("event_id")
        .as("rc");

    // =========================================================
    // กิจกรรมที่ User คนนี้ลงทะเบียนแล้ว
    // =========================================================

    const myRegistrationQuery =
      db("event_registrations")
        .select("event_id")
        .where({
          user_id: userId,
          status: "registered",
        })
        .as("mr");

    // =========================================================
    // Query
    // =========================================================

    const query = db("events as e")
      .leftJoin(
        registrationCountQuery,
        "rc.event_id",
        "e.id"
      )
      .leftJoin(
        myRegistrationQuery,
        "mr.event_id",
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
        db.raw(
          "COALESCE(rc.registered_count, 0) AS registered_count"
        )
      )
      .select(
        db.raw(
          "CASE WHEN mr.event_id IS NULL THEN 0 ELSE 1 END AS is_registered"
        )
      );

    // =========================================================
    // User ไม่ควรเห็น Draft / Cancelled
    // =========================================================

    if (
      status === "open" ||
      status === "closed" ||
      status === "completed"
    ) {
      query.where(
        "e.status",
        status
      );
    } else {
      query.whereIn(
        "e.status",
        [
          "open",
          "closed",
          "completed",
        ]
      );
    }

    // =========================================================
    // Search
    // =========================================================

    if (search) {
      query.andWhere(
        function () {
          this.where(
            "e.title",
            "like",
            `%${search}%`
          ).orWhere(
            "e.location_name",
            "like",
            `%${search}%`
          );
        }
      );
    }

    // เปิดรับก่อน > ปิดรับ > จบแล้ว
    query
      .orderByRaw(`
        CASE
          WHEN e.status = 'open' THEN 0
          WHEN e.status = 'closed' THEN 1
          WHEN e.status = 'completed' THEN 2
          ELSE 3
        END
      `)
      .orderBy(
        "e.start_at",
        "asc"
      );

    const events =
      await query;

    return res.status(200).json({
      success: true,

      total:
        events.length,

      events:
        events.map(
          (event) => ({
            ...event,

            registered_count:
              Number(
                event.registered_count ??
                  0
              ),

            is_registered:
              Number(
                event.is_registered ??
                  0
              ) === 1,
          })
        ),
    });
  } catch (error) {
    console.error(
      "GET USER EVENTS ERROR:",
      error
    );

    return res.status(500).json({
      success: false,
      message:
        "ไม่สามารถโหลดกิจกรรมได้",
    });
  }
};

// =============================================================
// GET USER EVENT DETAIL
// =============================================================

export const getUserEventDetail = async (
  req: Request,
  res: Response
) => {
  try {
    const userId = Number(
      (req as any).user?.id
    );

    const eventId = Number(
      req.params.id
    );

    if (!userId) {
      return res.status(401).json({
        success: false,
        message: "กรุณาเข้าสู่ระบบ",
      });
    }

    if (!eventId) {
      return res.status(400).json({
        success: false,
        message: "รหัสกิจกรรมไม่ถูกต้อง",
      });
    }

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
        "status"
      )
      .where("id", eventId)
      .whereIn(
        "status",
        [
          "open",
          "closed",
          "completed",
        ]
      )
      .first();

    if (!event) {
      return res.status(404).json({
        success: false,
        message:
            "ไม่พบกิจกรรมหรือกิจกรรมนี้ไม่สามารถแสดงได้",
      });
    }

    // =========================================================
    // จำนวนผู้ลงทะเบียน
    // =========================================================

    const countResult =
        await db("event_registrations")
          .where({
            event_id: eventId,
            status: "registered",
          })
          .count("* as count")
          .first();

    const registeredCount =
        Number(
          countResult?.count ?? 0
        );

    // =========================================================
    // User ลงทะเบียนหรือยัง
    // =========================================================

    const registration =
        await db("event_registrations")
          .where({
            event_id: eventId,
            user_id: userId,
            status: "registered",
          })
          .first();

    // =========================================================
    // User Check-in หรือยัง
    // =========================================================

    const checkin =
        await db("checkins")
          .where({
            event_id: eventId,
            user_id: userId,
          })
          .first();

    return res.status(200).json({
      success: true,

      event: {
        ...event,

        registered_count:
            registeredCount,

        is_registered:
            registration != null,

        is_checked_in:
            checkin != null,

        checked_in_at:
            checkin?.checked_in_at ??
            null,

        checkin_distance:
            checkin?.distance_meters ??
            null,
      },
    });
  } catch (error) {
    console.error(
      "GET USER EVENT DETAIL ERROR:",
      error
    );

    return res.status(500).json({
      success: false,
      message:
          "ไม่สามารถโหลดรายละเอียดกิจกรรมได้",
    });
  }
};

// =============================================================
// REGISTER EVENT
// =============================================================

export const registerEvent = async (
  req: Request,
  res: Response
) => {
  try {
    const userId = Number(
      (req as any).user?.id
    );

    const eventId = Number(
      req.params.id
    );

    if (!userId) {
      return res.status(401).json({
        success: false,
        message: "กรุณาเข้าสู่ระบบ",
      });
    }

    if (!eventId) {
      return res.status(400).json({
        success: false,
        message: "รหัสกิจกรรมไม่ถูกต้อง",
      });
    }

    const result =
        await db.transaction(
      async (trx) => {
        // Lock กิจกรรมไว้ชั่วคราว
        // ป้องกันคนสมัครพร้อมกันจนเกินจำนวน
        const event =
            await trx("events")
              .where(
                "id",
                eventId
              )
              .forUpdate()
              .first();

        if (!event) {
          return {
            status: 404,
            success: false,
            message:
                "ไม่พบกิจกรรม",
          };
        }

        if (
          event.status !==
          "open"
        ) {
          return {
            status: 400,
            success: false,
            message:
                "กิจกรรมนี้ไม่ได้เปิดรับสมัคร",
          };
        }

        // =====================================================
        // ตรวจของเดิม
        // =====================================================

        const existing =
            await trx(
              "event_registrations"
            )
              .where({
                user_id: userId,
                event_id: eventId,
              })
              .first();

        if (
          existing &&
          existing.status ===
              "registered"
        ) {
          return {
            status: 400,
            success: false,
            message:
                "คุณลงทะเบียนกิจกรรมนี้แล้ว",
          };
        }

        // =====================================================
        // ตรวจจำนวนคน
        // =====================================================

        const countResult =
            await trx(
              "event_registrations"
            )
              .where({
                event_id: eventId,
                status: "registered",
              })
              .count(
                "* as count"
              )
              .first();

        const registeredCount =
            Number(
              countResult?.count ??
                  0
            );

        if (
          event.max_participants !=
              null &&
          registeredCount >=
              Number(
                event.max_participants
              )
        ) {
          return {
            status: 400,
            success: false,
            message:
                "กิจกรรมนี้มีผู้ลงทะเบียนเต็มแล้ว",
          };
        }

        // =====================================================
        // เคยยกเลิกไว้ -> เปิดกลับเป็น registered
        // =====================================================

        if (existing) {
          await trx(
            "event_registrations"
          )
              .where(
                "id",
                existing.id
              )
              .update({
                status:
                    "registered",

                registered_at:
                    trx.fn.now(),

                updated_at:
                    trx.fn.now(),
              });
        } else {
          // ===================================================
          // สมัครใหม่
          // ===================================================

          await trx(
            "event_registrations"
          ).insert({
            user_id:
                userId,

            event_id:
                eventId,

            status:
                "registered",

            registered_at:
                trx.fn.now(),

            created_at:
                trx.fn.now(),

            updated_at:
                trx.fn.now(),
          });
        }

        return {
          status: 200,
          success: true,
          message:
              "ลงทะเบียนกิจกรรมสำเร็จ",
        };
      }
    );

    return res
        .status(result.status)
        .json({
      success:
          result.success,

      message:
          result.message,
    });
  } catch (error) {
    console.error(
      "REGISTER EVENT ERROR:",
      error
    );

    return res.status(500).json({
      success: false,
      message:
          "ไม่สามารถลงทะเบียนกิจกรรมได้",
    });
  }
};

// =============================================================
// CHECK-IN EVENT
// =============================================================

export const checkInEvent = async (
  req: Request,
  res: Response
) => {
  try {
    const userId =
      Number(
        (req as any)
          .user?.id
      );

    const eventId =
      Number(
        req.params.id
      );

    const latitude =
      Number(
        req.body.latitude
      );

    const longitude =
      Number(
        req.body.longitude
      );

    // =========================================================
    // Validate User
    // =========================================================

    if (!userId) {
      return res
        .status(401)
        .json({
          success:
            false,

          message:
            "กรุณาเข้าสู่ระบบ",
        });
    }

    // =========================================================
    // Validate Event ID
    // =========================================================

    if (
      !eventId ||
      Number.isNaN(
        eventId
      )
    ) {
      return res
        .status(400)
        .json({
          success:
            false,

          message:
            "รหัสกิจกรรมไม่ถูกต้อง",
        });
    }

    // =========================================================
    // Validate GPS
    // =========================================================

    if (
      !Number.isFinite(
        latitude
      ) ||
      latitude < -90 ||
      latitude > 90
    ) {
      return res
        .status(400)
        .json({
          success:
            false,

          message:
            "Latitude ไม่ถูกต้อง",
        });
    }

    if (
      !Number.isFinite(
        longitude
      ) ||
      longitude < -180 ||
      longitude > 180
    ) {
      return res
        .status(400)
        .json({
          success:
            false,

          message:
            "Longitude ไม่ถูกต้อง",
        });
    }

    // =========================================================
    // Event
    // =========================================================

    const event =
      await db("events")
        .where(
          "id",
          eventId
        )
        .first();

    if (!event) {
      return res
        .status(404)
        .json({
          success:
            false,

          message:
            "ไม่พบกิจกรรม",
        });
    }

    // =========================================================
    // Event Status
    // open / closed สามารถเช็กอินได้
    // closed = ปิดสมัคร แต่ยังอาจอยู่ในช่วงกิจกรรม
    // =========================================================

    if (
      event.status ===
        "draft" ||
      event.status ===
        "cancelled" ||
      event.status ===
        "completed"
    ) {
      return res
        .status(400)
        .json({
          success:
            false,

          message:
            "กิจกรรมนี้ไม่สามารถเช็กอินได้",
        });
    }

    // =========================================================
    // Check Registration
    // =========================================================

    const registration =
      await db(
        "event_registrations"
      )
        .where({
          user_id:
            userId,

          event_id:
            eventId,

          status:
            "registered",
        })
        .first();

    if (!registration) {
      return res
        .status(403)
        .json({
          success:
            false,

          message:
            "คุณยังไม่ได้ลงทะเบียนกิจกรรมนี้",
        });
    }

    // =========================================================
    // Duplicate Check-in
    // =========================================================

    const existingCheckin =
      await db(
        "checkins"
      )
        .where({
          user_id:
            userId,

          event_id:
            eventId,
        })
        .first();

    if (existingCheckin) {
      return res
        .status(400)
        .json({
          success:
            false,

          message:
            "คุณเช็กอินกิจกรรมนี้แล้ว",

          checkin: {
            checked_in_at:
              existingCheckin
                .checked_in_at,

            distance_meters:
              Number(
                existingCheckin
                  .distance_meters
              ),
          },
        });
    }

    // =========================================================
    // Check-in Time
    // =========================================================

    if (
      !event
        .checkin_start_at ||
      !event
        .checkin_end_at
    ) {
      return res
        .status(400)
        .json({
          success:
            false,

          message:
            "กิจกรรมนี้ยังไม่ได้กำหนดช่วงเวลาเช็กอิน",
        });
    }

    const now =
      new Date();

    const checkinStart =
      new Date(
        event
          .checkin_start_at
      );

    const checkinEnd =
      new Date(
        event
          .checkin_end_at
      );

    if (
      now <
      checkinStart
    ) {
      return res
        .status(400)
        .json({
          success:
            false,

          message:
            "ยังไม่ถึงเวลาเปิดเช็กอิน",

          checkin_start_at:
            event
              .checkin_start_at,
        });
    }

    if (
      now >
      checkinEnd
    ) {
      return res
        .status(400)
        .json({
          success:
            false,

          message:
            "หมดเวลาเช็กอินแล้ว",

          checkin_end_at:
            event
              .checkin_end_at,
        });
    }

    // =========================================================
    // Event Position
    // =========================================================

    const eventLatitude =
      Number(
        event.latitude
      );

    const eventLongitude =
      Number(
        event.longitude
      );

    const allowedRadius =
      Number(
        event
          .checkin_radius
      );

    if (
      !Number.isFinite(
        eventLatitude
      ) ||
      !Number.isFinite(
        eventLongitude
      ) ||
      !Number.isFinite(
        allowedRadius
      )
    ) {
      return res
        .status(500)
        .json({
          success:
            false,

          message:
            "ข้อมูลตำแหน่งกิจกรรมไม่ถูกต้อง",
        });
    }

    // =========================================================
    // Calculate Distance
    // =========================================================

    const distance =
      calculateDistanceMeters(
        eventLatitude,
        eventLongitude,
        latitude,
        longitude
      );

    const distanceMeters =
      Number(
        distance.toFixed(
          2
        )
      );

    // =========================================================
    // Outside Radius
    // =========================================================

    if (
      distance >
      allowedRadius
    ) {
      return res
        .status(400)
        .json({
          success:
            false,

          message:
            "คุณอยู่นอกพื้นที่เช็กอิน",

          distance_meters:
            distanceMeters,

          allowed_radius:
            allowedRadius,
        });
    }

    // =========================================================
    // INSERT CHECK-IN
    // =========================================================

    await db(
      "checkins"
    ).insert({
      user_id:
        userId,

      event_id:
        eventId,

      latitude:
        latitude,

      longitude:
        longitude,

      distance_meters:
        distanceMeters,

      checked_in_at:
        db.fn.now(),

      created_at:
        db.fn.now(),
    });

    // =========================================================
    // Success
    // =========================================================

    return res
      .status(200)
      .json({
        success:
          true,

        message:
          "เช็กอินสำเร็จ",

        checkin: {
          distance_meters:
            distanceMeters,

          allowed_radius:
            allowedRadius,

          latitude:
            latitude,

          longitude:
            longitude,

          checked_in_at:
            new Date(),
        },
      });
  } catch (error: any) {
    console.error(
      "CHECK-IN EVENT ERROR:",
      error
    );

    // Unique Constraint
    if (
      error?.code ===
      "ER_DUP_ENTRY"
    ) {
      return res
        .status(400)
        .json({
          success:
            false,

          message:
            "คุณเช็กอินกิจกรรมนี้แล้ว",
        });
    }

    return res
      .status(500)
      .json({
        success:
          false,

        message:
          "ไม่สามารถเช็กอินกิจกรรมได้",
      });
  }
};

// =============================================================
// GET MY EVENT HISTORY
// =============================================================

export const getMyEventHistory = async (
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

    const rows = await db(
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

      .select(
        "e.id as event_id",
        "e.title",
        "e.description",
        "e.location_name",
        "e.start_at",
        "e.end_at",
        "e.checkin_start_at",
        "e.checkin_end_at",
        "e.status as event_status",

        "er.status as registration_status",
        "er.registered_at",

        "c.id as checkin_id",
        "c.checked_in_at",
        "c.distance_meters",
        "c.latitude as checkin_latitude",
        "c.longitude as checkin_longitude"
      )

      .where(
        "er.user_id",
        userId
      )

      .orderBy(
        "e.start_at",
        "desc"
      );

    const history = rows.map(
      (row) => ({
        event_id:
          row.event_id,

        title:
          row.title,

        description:
          row.description,

        location_name:
          row.location_name,

        start_at:
          row.start_at,

        end_at:
          row.end_at,

        checkin_start_at:
          row.checkin_start_at,

        checkin_end_at:
          row.checkin_end_at,

        event_status:
          row.event_status,

        registration_status:
          row.registration_status,

        registered_at:
          row.registered_at,

        is_checked_in:
          row.checkin_id != null,

        checked_in_at:
          row.checked_in_at,

        distance_meters:
          row.distance_meters == null
            ? null
            : Number(
                row.distance_meters
              ),

        checkin_latitude:
          row.checkin_latitude,

        checkin_longitude:
          row.checkin_longitude,
      })
    );

    return res.status(200).json({
      success: true,

      total:
        history.length,

      history:
        history,
    });
  } catch (error) {
    console.error(
      "GET MY EVENT HISTORY ERROR:",
      error
    );

    return res.status(500).json({
      success: false,
      message:
        "ไม่สามารถโหลดประวัติการเข้าร่วมได้",
    });
  }
};

// =============================================================
// GET CHECK-IN CENTER
// =============================================================

export const getCheckinCenter = async (
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

    // จำนวนผู้ลงทะเบียนแต่ละกิจกรรม
    const registrationCountSubquery = db(
      "event_registrations"
    )
      .select("event_id")
      .count("* as registered_count")
      .where(
        "status",
        "registered"
      )
      .groupBy("event_id")
      .as("rc");

    const events = await db(
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
        registrationCountSubquery,
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
        "draft"
      )

      .whereNot(
        "e.status",
        "cancelled"
      )

      .orderBy(
        "e.start_at",
        "asc"
      );

    const result = events.map(
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
          event.distance_meters ==
          null
              ? null
              : Number(
                  event.distance_meters
                ),
      })
    );

    return res.status(200).json({
      success: true,
      total:
        result.length,
      events:
        result,
    });
  } catch (error) {
    console.error(
      "GET CHECK-IN CENTER ERROR:",
      error
    );

    return res.status(500).json({
      success: false,
      message:
        "ไม่สามารถโหลดข้อมูลเช็กอินได้",
    });
  }
};
