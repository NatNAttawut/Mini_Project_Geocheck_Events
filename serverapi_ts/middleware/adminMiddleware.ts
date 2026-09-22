import { Request, Response, NextFunction } from "express";

export const adminMiddleware = (
  req: Request,
  res: Response,
  next: NextFunction
) => {
  const user = (req as any).user;

  if (!user) {
    return res.status(401).json({
      success: false,
      message: "กรุณาเข้าสู่ระบบ",
    });
  }

  if (
    user.role !== "admin" &&
    user.role !== "super_admin"
  ) {
    return res.status(403).json({
      success: false,
      message: "คุณไม่มีสิทธิ์ใช้งานส่วนนี้",
    });
  }

  next();
};
