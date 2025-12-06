# 🐾 PawPal

App for the animal lover <3

## 🛠️ Setup 

1.  **Dependencies:** Run `flutter pub get`.
2.  **Server:** Install and start **XAMPP**.
3.  **Database:** Import `pawpal_db.sql`.
4.  **API Files:** Copy `API` and `uploads` folders to XAMPP root (`htdocs`).
5.  **Config:** Update IP address in `myconfig.dart`.
6.  **Run:** Start the `main.dart` file.

---

## 🌐 API Endpoints

| File | Purpose |
| :--- | :--- |
| **`dbconnect.php`** | Connects to DB. |
| **`login.php`** | User Login. |
| **`register_user.php`** | User Registration. |
| **`get_my_pets.php`** | Loads/Searches pets. |
| **`submit_pets.php`** | Adds new pets/images. |

---

## 💻 Sample Responses

### 1. Pet List (`get_my_pets.php`)

| Status | Meaning | Data Example |
| :--- | :--- | :--- |
| `"success"` | Pet data returned. | `{"status": "success", "data": [{"pet_id": "3", ...}]}` |
| `"failed"` | No pets found. | `{"status": "failed", "data": []}` |

### 2. Pet Submission (`submit_pets.php`)

| Status | Message | Example |
| :--- | :--- | :--- |
| `"success"` | Pet added successfully. | `{"status": "success", "message": "Pet added successfully"}` |
| `"failed"` | Error (e.g., missing images). | `{"status": "failed", "message": "No images provided"}` |