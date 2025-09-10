import mongoose from "mongoose";

const reportSchema = new mongoose.Schema({
  image_url: {
    type: String,
  },
  text: {
    type: String,
    required: true,
  },
  transcription: {
    type: String,
  },
  location: {
    type: {
      type: String,
      enum: ["Point"],
      required: true,
      default: "Point",
    },
    coordinates: {
      type: [Number], // [longitude, latitude]
      required: true,
    },
  },
  summary: {
    type: String,
  },
  status: {
    type: String,
    enum: ["Submitted", "Acknowledged", "Assigned", "Resolved", "Rejected"],
    required: true,
    default: "Submitted",
    index: true,
  },
  createdBy: {
    type: mongoose.Schema.Types.ObjectId,
    ref: "User",
    required: true,
    index: true,
  },
  handledBy: {
    type: mongoose.Schema.Types.ObjectId,
    ref: "Admin",
  },
  priority: {
    type: String,
    enum: ["Low", "Medium", "High"],
    required: true,
  },
  category: {
    type: String,
    required: true,
  },
  assignedTo: {
    type: mongoose.Schema.Types.ObjectId,
    ref: "Department",
    index: true,
  },
}, { timestamps: true });

reportSchema.index({ location: "2dsphere" });

export default mongoose.model("Report", reportSchema);
