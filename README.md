# Inkwell - Thoughtful Writing

A full-stack mobile blog application built with Flutter and Node.js. 
Inkwell allows users to read, write, and react to thoughtfully curated blogs.

## 🚀 Features

- **Read & Write Articles:** Seamlessly read articles, and authors can write new articles using markdown.
- **Dynamic Theming:** Built-in Light and Dark modes.
- **Authentication:** Secure user signup and sign-in functionality.
- **Interactive UI:** Smooth transitions, responsive design, shimmer loading effects, and micro-animations.
- **Reactions:** Like articles and see what others are engaging with.
- **Profile Dashboard:** View your stats, liked articles, and author tools (if permitted).

---

## 📁 Folder Structure

The repository is organized into two main parts:

- `frontend/` - Contains the Flutter application.
- `backend/` - Contains the Node.js (Express + MongoDB) REST API.

---

## 🛠️ Backend Setup (Node.js)

1. **Navigate to the backend directory:**
   ```bash
   cd backend
   ```

2. **Install dependencies:**
   ```bash
   npm install
   ```

3. **Configure Environment Variables:**
   - Copy the `.env.example` file to `.env`:
     ```bash
     cp .env.example .env
     ```
   - Open `.env` and fill in your secrets (e.g., MongoDB URI, JWT Secret).
   - Ensure you never commit your actual `.env` file to version control.

4. **Start the server:**
   ```bash
   npm run dev
   # or
   node index.js
   ```
   The backend should now be running (usually on `http://localhost:8000`).

---

## 📱 Frontend Setup (Flutter)

1. **Navigate to the frontend directory:**
   ```bash
   cd frontend
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Configure Environment Variables:**
   - Copy the `.env.example` file to `.env`:
     ```bash
     cp .env.example .env
     ```
   - Open `.env` and set your `API_BASE_URL`.
     - For Linux/macOS/Windows desktop: `http://127.0.0.1:8000/api`
     - For Android Emulator: `http://10.0.2.2:8000/api`
     - For real devices, use your computer's local IP address.

4. **Run the App:**
   ```bash
   flutter run
   ```

## 🔒 Security Notes

- The `frontend/.env` and `backend/.env` files have been added to `.gitignore`. They will not be pushed to GitHub to prevent exposing API keys and secrets.
- Always use the `.env.example` files to document required variables for other developers.
