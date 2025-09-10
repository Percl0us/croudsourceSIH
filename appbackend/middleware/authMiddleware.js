import jwt from "jsonwebtoken";
const JWT_SECRET = "supersecret";

export const authMiddleware = (req, res, next) => {
  const token = req.headers.authorization?.split(" ")[1];
  if (!token) return res.status(401).json({ message: "No token provided" });

  try {
    const decoded = jwt.verify(token, JWT_SECRET);
    req.user = decoded; // { id: userId }
    next();
  } catch (err) {
    return res.status(401).json({ message: "Invalid token" });
  }
};
