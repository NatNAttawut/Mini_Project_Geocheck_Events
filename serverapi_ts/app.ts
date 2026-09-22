import express from "express";
import cors from "cors";

import authRoutes from "./routes/authRoutes";
import adminUserRoutes from "./routes/adminUserRoutes";
import adminEventRoutes from "./routes/adminEventRoutes";
import adminReportRoutes from "./routes/adminReportRoutes";
import adminDashboardRoutes from "./routes/adminDashboardRoutes";
import userEventRoutes from "./routes/userEventRoutes";
import profileRoutes from "./routes/profileRoutes";
import userHomeRoutes from "./routes/userHomeRoutes";
import adminAccessRoutes from "./routes/adminAccessRoutes";

const app = express();

// Middleware
app.use(cors());
app.use(express.json());
app.use(
  express.urlencoded({
    extended: true,
  })
);

// ============================================================
// Routes
// ============================================================

app.use("/api/auth", authRoutes);

app.use(
  "/api/admin/users",
  adminUserRoutes
);

app.use(
  "/api/admin/events",
  adminEventRoutes
);

app.use(
  "/api/admin/reports",
  adminReportRoutes
);

app.use(
  "/api/admin/dashboard",
  adminDashboardRoutes
);

app.use(
  "/api/admin/access",
  adminAccessRoutes
);

app.use(
  "/api/events",
  userEventRoutes
);

app.use(
  "/api/profile",
  profileRoutes
);

app.use(
  "/api/home",
  userHomeRoutes
);

// ============================================================
// Test API
// ============================================================

app.get("/", (req, res) => {
  res.json({
    status: "success",
    message:
      "GeoCheck Event API is running",
  });
});

export default app;