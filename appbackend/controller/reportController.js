
import Report from "../models/report.js";

export const createReport = async (req, res) => {
  try {
    const {
      image_url,
      text,
      transcription,
      location,
      summary,
      priority,
      category,
    } = req.body;
    if (!text || !priority || !category || !location) {
      return res.status(400).json({ message: "Missing required fileds" });
    }
    const report = new Report({
      image_url,
      text,
      transcription,
      location,
      summary,
      priority,
      category,
      createdBy: req.user.id,
    });
    await report.save();
    res.status(201).json({ message: "Report created succefully", report });
  } catch (error) {
    res.status(500).json({ messaeg: "Server error", error: error.message });
  }
};
export const getMyReoports = async (req, res) => {
  try {
    const reports = await Report.find({ createdBy: req.user.id }).sort({
      createdAt: -1,
    });
    res.json(reports);
  } catch (error) {
    res.status(500).json({ message: "Server Error", error: error.message });
  }
};
export const getReportById = async (req, res) => {
  try {
    const report = await Report.findById(req.params.id);
    if (!report) return res.status(404).json({ message: "report not found" });
    res.json(report);
  } catch (error) {
    res.status(500).json({ message: "Server erorr", error: error.message });
  }
};
