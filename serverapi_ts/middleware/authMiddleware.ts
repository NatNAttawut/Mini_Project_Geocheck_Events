import {
  Request,
  Response,
  NextFunction,
} from "express";

import jwt, {
  JwtPayload,
  Secret,
} from "jsonwebtoken";

const JWT_SECRET: Secret =
  process.env.JWT_SECRET || "geocheck_default_secret";

export interface AuthRequest extends Request {
  user?: {
    id: number;
    email: string;
    role: string;
  };
}

interface TokenPayload extends JwtPayload {
  id: number;
  email: string;
  role: string;
}

export const authenticateToken = (
  req: AuthRequest,
  res: Response,
  next: NextFunction
): void => {
  // Authorization: Bearer TOKEN
  const authHeader =
    req.headers.authorization;

  if (!authHeader) {
    res.status(401).json({
      success: false,
      message: "ไม่พบ Token",
    });

    return;
  }

  const parts = authHeader.split(" ");

  if (
    parts.length !== 2 ||
    parts[0] !== "Bearer"
  ) {
    res.status(401).json({
      success: false,
      message: "รูปแบบ Token ไม่ถูกต้อง",
    });

    return;
  }

  const token = parts[1];

  try {
    const decoded = jwt.verify(
      token,
      JWT_SECRET
    ) as TokenPayload;

    req.user = {
      id: decoded.id,
      email: decoded.email,
      role: decoded.role,
    };

    next();
  } catch (error) {
    res.status(401).json({
      success: false,
      message:
        "Token ไม่ถูกต้องหรือหมดอายุ",
    });
  }
};

// =============================================================
// ADMIN OR SUPER ADMIN
// =============================================================

export const requireAdmin = (
  req: Request,
  res: Response,
  next: NextFunction
) => {
  const role = (req as any).user?.role;

  if (
    role !== "admin" &&
    role !== "super_admin"
  ) {
    return res.status(403).json({
      success: false,
      message:
        "คุณไม่มีสิทธิ์เข้าถึงส่วนผู้ดูแลระบบ",
    });
  }

  next();
};

// =============================================================
// SUPER ADMIN ONLY
// =============================================================

export const requireSuperAdmin = (
  req: Request,
  res: Response,
  next: NextFunction
) => {
  const role = (req as any).user?.role;

  if (role !== "super_admin") {
    return res.status(403).json({
      success: false,
      message:
        "เฉพาะผู้ดูแลระบบหลักเท่านั้นที่จัดการสิทธิ์ได้",
    });
  }

  next();
};
