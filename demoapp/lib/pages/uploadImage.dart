// lib/pages/upload_image_page.dart
import 'dart:io';
import 'package:demoapp/helpers/persmission_helper.dart';
import 'package:demoapp/pages/map_picker_page.dart';
import 'package:demoapp/services/auth_service.dart';
import 'package:demoapp/services/report_service.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

class UploadImagePage extends StatefulWidget {
  const UploadImagePage({super.key});

  @override
  State<UploadImagePage> createState() => _UploadImagePageState();
}

class _UploadImagePageState extends State<UploadImagePage> {
  File? _image;
  bool _busy = false;
  String? _uploadedUrl;
  final _textCtrl = TextEditingController();
  String _category = "Road";
  String _priority = "Medium";
  LatLng? _pickedLatLng;

  final ReportService _reportService = ReportService();
  final ImagePicker _picker = ImagePicker();

  // 📷 Pick from camera
  Future<void> _pickFromCamera() async {
    final granted = await PermissionHelper.requestCamera();
    if (!mounted) return;
    if (!granted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Camera permission required")),
      );
      return;
    }

    final x = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
    );
    if (!mounted) return;
    if (x != null) setState(() => _image = File(x.path));
  }

  // 🖼️ Pick from gallery
  Future<void> _pickFromGallery() async {
    final granted = await PermissionHelper.requestGallery();
    if (!mounted) return;
    if (!granted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Gallery permission required")),
      );
      return;
    }

    final x = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (!mounted) return;
    if (x != null) setState(() => _image = File(x.path));
  }

  // 🌍 Pick location via map
  Future<void> _pickLocation() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => MapPickerPage()),
    );
    if (result != null && mounted) {
      setState(() => _pickedLatLng = result as LatLng);
    }
  }

  // 📌 Use current location
  Future<void> _useCurrentLocation() async {
    final granted = await PermissionHelper.requestLocation();
    if (!mounted) return;
    if (!granted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Location permission required")),
      );
      return;
    }

    try {
      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _pickedLatLng = LatLng(pos.latitude, pos.longitude);
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error getting location: $e")));
    }
  }
 Future<void> _logout() async {
    await AuthService().logout(); // clear token/session
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, "/login");
  }
  // 🚀 Upload and create report
  Future<void> _uploadAndCreate() async {
    if (_image == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please select an image")));
      return;
    }
    if (_textCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please add a description")));
      return;
    }
    if (_pickedLatLng == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please select a location")));
      return;
    }

    try {
      setState(() {
        _busy = true;
        _uploadedUrl = null;
      });

      // 1) Upload to Cloudinary
      print("Uploading to Cloudinary...");
      final secureUrl = await _reportService.uploadImageToCloudinary(_image!);
      print("Cloudinary done: $secureUrl");
      setState(() => _uploadedUrl = secureUrl);

      // 2) Create report in backend
      print("Sending to backend...");
      await _reportService.createReport(
        imageUrl: secureUrl,
        text: _textCtrl.text.trim(),
        latitude: _pickedLatLng!.latitude,
        longitude: _pickedLatLng!.longitude,
        priority: _priority,
        category: _category,
      );
      print("Backend done!");

      // success
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Report created successfully")),
      );

      setState(() {
        _image = null;
        _textCtrl.clear();
        _uploadedUrl = null;
        _pickedLatLng = null;
      });
    } catch (e) {
      debugPrint("Upload/create error: $e");
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: ${e.toString()}")));
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  @override
  void dispose() {
    _textCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Upload the report here"),
        actions: [
          IconButton(
            icon: const Icon(Icons.list_alt),
            tooltip: "My Reports",
            onPressed: () {
              Navigator.pushNamed(context, "/my-reports");
            },
          ),
        ],
      ),
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 🖼️ Image preview
              if (_image != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    _image!,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                )
              else
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.grey.shade200,
                  ),
                  child: const Center(child: Text("No image selected")),
                ),
              const SizedBox(height: 12),

              // 📷 Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _busy ? null : _pickFromCamera,
                      icon: const Icon(Icons.camera_alt),
                      label: const Text("Camera"),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _busy ? null : _pickFromGallery,
                      icon: const Icon(Icons.photo_library),
                      label: const Text("Gallery"),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // 📝 Description
              TextField(
                controller: _textCtrl,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: "Description",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),

              // Category + Priority
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _category,
                      items: const [
                        DropdownMenuItem(value: "Road", child: Text("Road")),
                        DropdownMenuItem(
                          value: "Garbage",
                          child: Text("Garbage"),
                        ),
                        DropdownMenuItem(value: "Water", child: Text("Water")),
                        DropdownMenuItem(
                          value: "Electricity",
                          child: Text("Electricity"),
                        ),
                      ],
                      onChanged: (v) => setState(() => _category = v ?? "Road"),
                      decoration: const InputDecoration(labelText: "Category"),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _priority,
                      items: const [
                        DropdownMenuItem(value: "Low", child: Text("Low")),
                        DropdownMenuItem(
                          value: "Medium",
                          child: Text("Medium"),
                        ),
                        DropdownMenuItem(value: "High", child: Text("High")),
                      ],
                      onChanged: (v) =>
                          setState(() => _priority = v ?? "Medium"),
                      decoration: const InputDecoration(labelText: "Priority"),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // 🌍 Location buttons
              OutlinedButton.icon(
                onPressed: _busy ? null : _pickLocation,
                icon: const Icon(Icons.map),
                label: Text(
                  _pickedLatLng == null
                      ? "Pick Location on Map"
                      : "Picked: ${_pickedLatLng!.latitude.toStringAsFixed(4)}, ${_pickedLatLng!.longitude.toStringAsFixed(4)}",
                ),
              ),
              OutlinedButton.icon(
                onPressed: _busy ? null : _useCurrentLocation,
                icon: const Icon(Icons.my_location),
                label: const Text("Use Current Location"),
              ),
              const SizedBox(height: 16),

              // 🚀 Submit
              ElevatedButton(
                onPressed: _busy ? null : _uploadAndCreate,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                ),
                child: _busy
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Upload & Submit"),
              ),
              const SizedBox(height: 12),

              // 🌐 Uploaded URL
              if (_uploadedUrl != null) ...[
                const Text("Uploaded image URL:"),
                SelectableText(_uploadedUrl!),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
