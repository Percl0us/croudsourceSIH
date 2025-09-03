import express from "express";
import { login, profile, signup } from "../controller/authController";

const router = express.router();
router.post("/signup", signup);
router.post("/login", login);
router.get("/profile", profile);
export default router;