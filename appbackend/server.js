import express from 'express';
import cors from 'cors';
import connectDB from './config/db.js';
import authRoutes from './routes/authRoutes.js';
import { connect } from 'http2';

const app = express();
app.use(cors());
app.use(express.json());

connectDB();

app.use('/api/auth', authRoutes);
const PORT=3000;
app.listen(PORT,()=>console.log(`Server running on port ${PORT}`));