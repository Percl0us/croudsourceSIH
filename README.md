# Nivaran 🌍

A Flutter mobile application for reporting issues with **image upload, location picking, and authentication (signup/login)**.  
This project is built with Flutter and integrates **camera, gallery, and map picker functionality**.

---

## ✨ Features
- 📸 Upload images using **Camera** or **Gallery**
- 🗺️ Pick **current location** or choose a location from the map
- 🔐 Authentication (Signup & Login)
- ✅ Permissions handled for **Camera, Storage, and Location**
- 🌐 Backend integration via `AuthService` and `ApiService`

---

## 📂 Project Structure
lib/
├── helpers/
│ └── permission_helper.dart # Permission handling
├── pages/
│ ├── login_page.dart # Login UI
│ ├── signup_page.dart # Signup UI
│ └── upload_image_page.dart # Upload with map picker
├── services/
│ ├── api_service.dart # API Ping & requests
│ └── auth_service.dart # Authentication logic
├── widgets/
│ └── header_widget.dart # Reusable gradient header
└── main.dart # Entry point

---

## 🛠️ Setup Instructions

### 1️⃣ Clone Repository
```bash
git clone https://github.com/your-username/nirvana.git
cd nirvana
flutter pub get
    
