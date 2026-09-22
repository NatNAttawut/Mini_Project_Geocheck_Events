import dotenv from 'dotenv';
import app from './app';
import db from './utils/db';

dotenv.config();

const PORT = process.env.PORT || 3000;

async function startServer() {
  try {
    // ทดสอบการเชื่อมต่อฐานข้อมูล
    await db.raw('SELECT 1');

    console.log('Database connected successfully');

    app.listen(PORT, () => {
      console.log(`GeoCheck Event API running on port ${PORT}`);
      console.log(`http://localhost:${PORT}`);
    });
  } catch (error) {
    console.error('Database connection failed:', error);
    process.exit(1);
  }
}

startServer();