import express from "express";
import { login, profile, signup } from "../controller/authController.js";

const router = express.Router();
router.post("/signup", signup);
router.post("/login", login);
router.get("/profile", profile);
export default router;