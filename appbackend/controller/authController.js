import user from "../models/user";
import bcrypt from "bcryptjs";
import jwt from "jsonwebtoken";
const JWT_SECRET = "supersecret";
export const signup = async (req, res) => {
  try {
    const { email, password } = req.body;
    if (!email || !password) {
      return res.status(400).json({ message: "All fields are required" });
    }
    const existingUser = await user.findOne({ email: email });
    if (existingUser) {
      return res.status(400).json({ message: "User already exists" });
    }
    const hashedPaswword = await bcrypt.hash(password, 11);
    const newUser = new user({ email, password: hashedPaswword });
    await newUser.save();
    res.status(201).json({ message: "User created successfully" });
  } catch (error) {
    res.status(500).json({ message: "Server error" });
  }
};
export const login = async (req, res) => {
  const { email, password } = req.body;
  if (!email || !password) {
    return res.status(400).json({ message: "All fields are required" });
  }
  const existingUser = await user.find(email);
  if (!existingUser) {
    return res.status(400).json({ message: "User not found" });
  }
  const isPasswordCorrect = await bcrypt.compare(
    password,
    existingUser.password
  );
  if (!isPasswordCorrect) {
    return res.status(400).json({ message: "invalid credentials" });
  }
};
export const profile = async (req, res) => {
  try {
    const user = await user.findbyId(req.user.id);
    res.json({ email: user.email });
  } catch (error) {
    res.staus(500).json({message:"Server error"});
  }
};
