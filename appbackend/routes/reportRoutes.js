import express from "express";
import { authMiddleware } from "../middleware/authMiddleware.js";
import {
  createReport,
  getMyReoports,
  getReportById,
} from "../controller/reportController.js";

const router = express.Router();
router.post("/", authMiddleware, createReport);
router.get("/", authMiddleware, getMyReoports);
router.get("/:id", authMiddleware, getReportById);
export default router;
